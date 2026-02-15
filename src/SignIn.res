@react.component
let make = (~setHasAuth, ~client, ~votp) => {
  let {setUsername, setEmail} = FormHook.useForm()

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
        setHasAuth(_ => None)
        setLoginState(_ => SupaError.Auth(err)->Error)
      | (false, _, Value({user: Value(user)})) =>
        setLoginState(_ => Success())
        setHasAuth(_ => Some(user))
        setEmail(_ => user.email)
        setUsername(_ => user.user_metadata.username)
        Route.push(Landing)
      | (false, _, _) =>
        setHasAuth(_ => None)
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
      | Error(err) => <SupaErr err />
      | Success() => React.null
      }}
    </div>
  </>
}
