@react.component
let make = (~setHasAuth, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    Console.log("in sinin eff")
    let funfun = async () => {
      open Supabase
      Console.log("in func")
      let {error, data} = await client
      ->Client.auth
      ->Auth.verifyOtp(votp)

      Console.log3("votp", error, data)

      switch (ignoreUpdate.contents, error, data) {
      | (true, _, _) => ()
      | (false, Value(err), _) =>
        setHasAuth(_ => false)
        setUser(_ => None)
        setLoginState(_ => SupaError.Auth(err)->Error)
      | (false, _, Value({user: Value(user)})) =>
        setHasAuth(_ => true)
        setUser(_ => Some(user))
        setLoginState(_ => Success())
        Route.push(Landing)
      | (false, _, _) =>
        setHasAuth(_ => false)
        setUser(_ => None)
        setLoginState(_ => SupaError.authError->Error)
      }
    }

    funfun()->ignore

    Some(() => ignoreUpdate.contents = true)
  }, [])

  <>
    <Header />
    <div>
      {switch loginstate {
      | Loading => <Loading label="session" />
      | Error(err) => <SupaErrToast err />
      | Success() => React.null
      }}
    </div>
    <Footer />
  </>
}
