@react.component
let make = (~setHasAuth, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Auth.Loading)
  let loginOnce = React.useRef(false)

  let myfunc = async () => {
    open Supabase
    Console.log("in func")
    let resp = await client
    ->Client.auth
    ->Auth.verifyOtp(votp)

    Console.log2("votp", resp)
    resp->Auth.getResult
  }

  let funfun = async () => {
    switch await myfunc() {
    | Ok(resp) =>
      setHasAuth(_ => true)
      setUser(_ => Some(resp.user))
      setLoginState(_ => Success)
      Route.push(Landing)
    | Error(msg) =>
      setHasAuth(_ => false)
      setUser(_ => None)
      setLoginState(_ => Error(msg))
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
      | Error(err) => <SupaErr err />
      | Success => React.null
      }}
    </div>
    <Footer />
  </>
}
