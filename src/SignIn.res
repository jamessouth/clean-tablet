@react.component
let make = () => {
  let loginOnce = React.useRef(false)

  React.useEffect(() => {
    // let login = async () => {
    //     try {
    //       let response = await api.loginWithMagicLink(token);
    //       // Handle success (e.g., redirect or update user state)
    //     } catch (err) {
    //       // Handle error
    //     }
    //   };

    switch loginOnce.current {
    | true => Console.log("mimic sign in")
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
