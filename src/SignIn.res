type loginstage =
  | Loading
  | Error(Supabase.Auth.error)
  | Data(Supabase.Auth.authResp)

@react.component
let make = (~hasAuth, ~setHasAuth, ~setUser, ~user) => {
  let (loginstate, setLoginState) = React.useState(_ => Loading)
  let loginOnce = React.useRef(false)

  React.useEffect(() => {
    switch res {
    | Ok(user) =>
      setHasAuth(_ => true)
      setUser(_ => Some(user))
      setLoginState(_ => Data(user))
    | Error(msg) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ => Error(msg))
    }

    switch loginOnce.current {
    | true =>
      Console.log("mimic sign in")
      getLogin()->ignore
    | false => loginOnce.current = true
    }
    Console.log2(hasAuth, user)

    None
  }, [])

  <>
    <Header />
    <div>
      {switch loginstate {
      | Loading => <Loading label="user" />
      | Error(msg) =>
        <p className="text-stone-100 bg-red-600 w-2/5 m-auto text-center"> {React.string(msg)} </p>
      | Data(userAndSession) =>
        Console.log(userAndSession)
        <p className="text-stone-100 text-center"> {React.string("Hello ")} </p>
      }}
    </div>
    <Footer />
  </>
}
