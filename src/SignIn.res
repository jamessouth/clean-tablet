@react.component
let make = (~setHasAuth, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)
  let loginOnce = React.useRef(false)

  let funfun = async () => {
    open Supabase
    Console.log("in func")
    let {error, data} = await client
    ->Client.auth
    ->Auth.verifyOtp(votp)

    Console.log3("votp", error, data)

    switch (error, data) {
    | (Value(err), _) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ => SupaError.Auth(err)->Error)
    | (_, Value({user: Value(user)})) =>
      setHasAuth(_ => true)
      setUser(_ => Some(user))
      setLoginState(_ => Success)
      Route.push(Landing)
    | (_, _) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ =>
        SupaError.Auth({
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
