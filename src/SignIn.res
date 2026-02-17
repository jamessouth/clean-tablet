@react.component
let make = (~setHasAuth, ~client, ~votp, ~setUsername, ~setEmail) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    Console.log2("signin start", ignoreUpdate)
    let funfun = async () => {
      open Supabase
      Console.log("signin func")
      let {error, data} = await client
      ->Client.auth
      ->Auth.verifyOtp(votp)

      Console.log3("signin data", error, data)

      switch ignoreUpdate.contents {
      | true => ()
      | false =>
        switch (error, data) {
        | (Value(err), _) =>
          setHasAuth(_ => None)
          setLoginState(_ => SupaError.Auth(err)->Error)
        | (_, Value({user: Value(user)})) =>
          setEmail(_ => Some(user.email))
          setUsername(_ => Some(user.user_metadata.username))
          setLoginState(_ => Success())
          setHasAuth(_ => Some(user))
        | (_, _) =>
          setHasAuth(_ => None)
          setLoginState(_ => SupaError.authError->Error)
        }
      }
    }

    funfun()->ignore
    Console.log2("signin end", ignoreUpdate)

    Some(() => ignoreUpdate := true)
  }, [votp])

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
