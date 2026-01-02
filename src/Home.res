// let username_max_length = 10
let email_max_length = 99

@react.component
let make = () => {
  let (email, _setEmail) = React.Uncurried.useState(_ => "")
  let (_validationError, setValidationError) = React.Uncurried.useState(_ => Some(
    "EMAIL: 5-99 length; enter a valid email address.",
  ))

  React.useEffect(() => {
    ErrorHook.useError(email, Email, setValidationError)
    None
  }, [email])

  //   React.useEffect0(() => {
  //     Js.log("signin use effect")

  //     ImageLoad.import_("./ImageLoad.bs")
  //     ->Promise.then(func => {
  //       Promise.resolve(func["bghand"](.))
  //     })
  //     ->ignore

  //     None
  //   })

  let on_Click = () => {
    Console.log("submit clckd")
    Route.push(SignIn)
  }
  <>
    <Header />
    <Form on_Click leg="Sign in" validationError=None>
      // <Input value=email propName="email" inputMode="email" setFunc=setEmail />
    </Form>
    <Footer />
  </>
}
