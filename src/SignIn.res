type user = {
  success: bool,
  userID: int,
}

type error = string

@scope("JSON") @val
external parseLogin: string => user = "parse"

@react.component
let make = (~setHasAuth) => {
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
            | true => setHasAuth(_ => true)
            | false => setHasAuth(_ => false)
            }
            Ok(resp)
          } catch {
          | JsExn(_) => {
              setHasAuth(_ => false)
              Error("error parsing json response")
            }
          }
        }
      | false => {
          let error = await response->Fetch.Response.text
          setHasAuth(_ => false)
          Error(error)
        }
      }
    }

    switch loginOnce.current {
    | true => {
        Console.log("mimic sign in")
        login({
          "id": 753,
        })->Console.log
      }
    | false => loginOnce.current = true
    }

    None
  }, [])

  <>
    <Header />
    <div>
      <p className="text-stone-100 text-center">
        {React.string("Click the link sent to your email to login.")}
      </p>
    </div>
    <Footer />
  </>
}
