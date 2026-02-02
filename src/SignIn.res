@react.component
let make = (~setHasAuth, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)
  let loginOnce = React.useRef(false)

  let myfunc = async () => {
    open Supabase
    Console.log("in func")
    let resp = await client
    ->Client.auth
    ->Auth.verifyOtp(votp)

    Console.log2("votp", resp)
    resp
  }

  let funfun = async () => {
    let {error, data} = await myfunc()
    switch (error, data) {
    | (Value(err), _) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ => Supabase.Error.Auth(err)->Error)
    | (_, Value({user: Value(user)})) =>
      setHasAuth(_ => true)
      setUser(_ => Some(user))
      setLoginState(_ => Success)
      Route.push(Landing)
    | (_, _) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ =>
        Supabase.Error.Auth({
          name: "VerifyOTPError",
          status: Nullable.make(0),
          code: Nullable.make("invalid_state"),
          message: "both data and error are null",
        })->Error
      )
    }
  }

  React.useEffect(() => {
    Console.log("in eff")
    switch loginOnce.current {
    | true => Console.log("remount nologin path")
    | false =>
      Console.log("mimic sign in")
      funfun()->ignore
    }

    Some(() => loginOnce.current = true)
  }, [])

  <>
    <Header />
    <div>
      {switch loginstate {
      | Loading => <Loading label="session" />
      | Error(err) => <SupaErrToast err />
      | Success => React.null
      }}
    </div>
    <Footer />
  </>
}
