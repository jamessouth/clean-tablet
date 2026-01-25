@react.component
let make = (~hasAuth, ~setHasAuth, ~user, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Auth.Loading)
  let loginOnce = React.useRef(false)

  let myfunc = async () => {
    Console.log("in func")
    let res = await client
    ->Supabase.Client.auth
    ->Supabase.Auth.verifyOtp(votp)

    Console.log(res)
    res
  }

  let funfun = async () => {
    let res = await myfunc()

    switch res {
    | Ok({user, _}) =>
      setHasAuth(_ => true)
      setUser(_ => Some(user))
      setLoginState(_ => Success)
    | Error(msg) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ => Error(msg))
    }

    Console.log2(hasAuth, user)
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
