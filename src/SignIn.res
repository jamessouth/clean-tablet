type user = {
  success: bool,
  userID: int,
}

type error = string

type loginstage =
  | Loading
  | Error(error)
  | Data(user)

@scope("JSON") @val
external parseLogin: string => user = "parse"

@react.component
let make = (~hasAuth, ~setHasAuth, ~setUser, ~user) => {
  let (loginstate, setLoginState) = React.useState(_ => Loading)
  let loginOnce = React.useRef(false)

  React.useEffect(() => {
    let login = async data => {
      open Fetch

      let response = await fetch(
        "http://localhost:8000/login",
        {
          method: #POST,
          body: data->JSON.stringifyAny->Belt.Option.getExn->Body.string,
          headers: Headers.fromObject({
            "Content-Type": "application/json",
          }),
          credentials: #"include",
        },
      )
      switch response->Response.ok {
      | true => {
          let json = await response->Response.json

          try {
            let resp = json->JSON.stringify->parseLogin
            switch resp.success {
            | true => Ok(resp)
            | false => Error("login fail")
            }
          } catch {
          | JsExn(_) => Error("error parsing json response")
          }
        }
      | false => {
          let error = await response->Fetch.Response.text
          Error(error)
        }
      }
    }

    let getLogin = async () => {
      let res = await login({
        "id": 753,
      })

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
      | Data(user) =>
        <p className="text-stone-100 text-center">
          {React.string(
            "Hello " ++ Int.toString(user.userID) ++ "Click the link sent to your email to login.",
          )}
        </p>
      }}
    </div>
    <Footer />
  </>
}
