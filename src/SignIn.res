let toks = Set.make()

@react.component
let make = (
  ~setHasAuth,
  ~client,
  ~votp: Supabase.Auth.verifyOtpParams,
  ~setUsername,
  ~setEmail,
) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    let funfun = async () => {
      open Supabase

      let {error, data} = await client
      ->Client.auth
      ->Auth.getSession

      Console.log3("sess", error, data)

      switch (error, data) {
      | (Value(err), _) =>
        setHasAuth(_ => None)
        setLoginState(_ => SupaError.Auth(err)->Error)
      | (_, {session: Value({user})}) =>
        Route.replace(
          SignIn({
            type_: #other,
            token_hash: "",
          }),
        )

        setEmail(_ => Some(user.email))
        setUsername(_ => Some(user.user_metadata.username))
        setLoginState(_ => Success())
        setHasAuth(_ => Some(user))
      | (_, _) =>
        Console.log("no session found")

        switch (votp.token_hash->String.length, toks->Set.has(votp.token_hash)) {
        | (0, _) =>
          setHasAuth(_ => None)
          setLoginState(_ =>
            SupaError.Auth({
              name: "AuthError",
              status: null,
              code: Nullable.make("invalid_token"),
              message: "token is empty",
            })->Error
          )
        | (_, true) => Console.log("token set")
        | (_, false) =>
          toks->Set.add(votp.token_hash)

          let {error, data} = await client
          ->Client.auth
          ->Auth.verifyOtp(votp)

          Console.log3("signin data", error, data)

          switch (error, data) {
          | (Value(err), _) =>
            setHasAuth(_ => None)
            setLoginState(_ => SupaError.Auth(err)->Error)
          | (_, Value({user: Value(user)})) =>
            Route.replace(
              SignIn({
                type_: #other,
                token_hash: "",
              }),
            )
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
    }

    funfun()->ignore

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
