type loginstate =
  | ...Supabase.Auth.loginstate
  | Data(Supabase.Auth.authResp)

@react.component
let make = (~hasAuth, ~setHasAuth, ~user, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Loading)
  let loginOnce = React.useRef(false)

  let myfunc = async () => {
    open Supabase
    Console.log("in func")
    let resp = await client
    ->Client.auth
    ->Auth.verifyOtp(votp)

    Console.log2("votp", resp)
    // data,error
    resp->Auth.getResult
  }

  let funfun = async () => {
    switch await myfunc() {
    | Ok(resp) =>
      setHasAuth(_ => true)
      setUser(_ => Some(resp.user))
      setLoginState(_ => Data(resp))
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
      | Error(err) => <SupaErr err />
      | Data(userAndSession) =>
        Console.log(userAndSession)
        <p className="text-stone-100 text-center"> {React.string("Hello ")} </p>
      }}
    </div>
    <Footer />
  </>
}
