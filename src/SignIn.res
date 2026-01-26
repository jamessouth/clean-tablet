type loginstate =
  | ...Supabase.Auth.loginstate
  | Data(Supabase.Auth.authResp)

let getResult = (rspn: Supabase.Auth.response<'data>): result<'data, Supabase.Auth.error> =>
  switch rspn.error->Nullable.toOption {
  | Some(er) => Error(er)
  | None =>
    switch rspn.data->Nullable.toOption {
    | Some(d) => Ok(d)
    | None =>
      Error({
        name: "ResultError",
        status: Nullable.make(0),
        code: Nullable.make("invalid_state"),
        message: "both data and error are null",
      })
    }
  }

@react.component
let make = (~hasAuth, ~setHasAuth, ~user, ~setUser, ~client, ~votp) => {
  let (loginstate, setLoginState) = React.useState(_ => Loading)
  let loginOnce = React.useRef(false)

  let myfunc = async () => {
    Console.log("in func")
    let resp = await client
    ->Supabase.Client.auth
    ->Supabase.Auth.verifyOtp(votp)

    Console.log2("votp", resp)
    // data,error
    let res = resp->getResult
  }

  let funfun = async () => {
    let res = await myfunc()

    switch res {
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
      | Error(msg) =>
        <p className="text-stone-100 bg-red-600 w-2/5 m-auto text-center">
          {React.string(
            msg.message ++
            " " ++
            {
              switch msg.status {
              | Some(n) => Int.toString(n)
              | None => ""
              }
            },
          )}
        </p>
      | Data(userAndSession) =>
        Console.log(userAndSession)
        <p className="text-stone-100 text-center"> {React.string("Hello ")} </p>
      }}
    </div>
    <Footer />
  </>
}
