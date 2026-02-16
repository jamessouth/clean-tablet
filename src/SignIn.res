@react.component
let make = (~setHasAuth, ~client, ~votp, ~setUsername, ~setEmail) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    Console.log2("in sinin eff", ignoreUpdate)
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
        setHasAuth(_ => None)
        setLoginState(_ => SupaError.Auth(err)->Error)
      | (false, _, Value({user: Value(user)})) =>
        setEmail(_ => Some(user.email))
        setUsername(_ => Some(user.user_metadata.username))
        setLoginState(_ => Success())
        setHasAuth(_ => Some(user))
      | (false, _, _) =>
        setHasAuth(_ => None)
        setLoginState(_ => SupaError.authError->Error)
      }
    }

    funfun()->ignore
    Console.log2("in sinin eff end", ignoreUpdate)

    Some(() => ignoreUpdate.contents = true)
  }, [])

  <>
    <Header />
    <div>
      {switch loginstate {
      | Loading => <Loading label="session" />
      | Error(err) => <SupaErr err />
      | Success() => React.null
      }}
    </div>
  </>
}
