@react.component
let make = () => {
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

      await response->Response.json
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
