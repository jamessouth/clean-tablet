let ignoreUpdate = ref(false)

@react.component
let make = (~setHasAuth, ~client, ~votp, ~setUsername, ~setEmail) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    Console.log2("signin start", ignoreUpdate.contents)
    switch ignoreUpdate.contents {
    | true => ()
    | false =>
      ignoreUpdate := true
      let funfun = async () => {
        open Supabase
        Console.log("signin func")
        let {error, data} = await client
        ->Client.auth
        ->Auth.verifyOtp(votp)

        Console.log3("signin data", error, data)

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

      funfun()->ignore
    }
    Console.log2("signin end", ignoreUpdate.contents)

    None
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
