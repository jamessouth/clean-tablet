let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
let unameRegex = /^\w{3,10}$/

type return = {
  formUsername: string,
  formEmail: string,
  formSubmitClicked: bool,
  validationError: bool,
  emailValdnError: option<string>,
  unameValdnError: option<string>,
  setFormUsername: (string => string) => unit,
  setFormEmail: (string => string) => unit,
  setFormSubmitClicked: (bool => bool) => unit,
  setValidationError: (bool => bool) => unit,
  setEmailValdnError: (option<string> => option<string>) => unit,
  setUnameValdnError: (option<string> => option<string>) => unit,
}

let useForm = () => {
  let (formUsername, setFormUsername) = React.useState(_ => "")
  let (formEmail, setFormEmail) = React.useState(_ => "")

  let (formSubmitClicked, setFormSubmitClicked) = React.Uncurried.useState(_ => false)

  let (validationError, setValidationError) = React.useState(_ => true)

  let (emailValdnError, setEmailValdnError) = React.useState(_ => Some(
    "enter a valid email address",
  ))

  let (unameValdnError, setUnameValdnError) = React.useState(_ => Some(
    "3-10 letters, numbers, and _ only",
  ))

  React.useEffect(() => {
    Console.log("email error")
    switch String.match(formEmail, emailRegex) {
    | None => setEmailValdnError(_ => Some("enter a valid email address"))
    | Some(_) => setEmailValdnError(_ => None)
    }
    None
  }, [formEmail])

  React.useEffect(() => {
    Console.log("uname error")
    switch String.match(formUsername, unameRegex) {
    | None => setUnameValdnError(_ => Some("3-10 letters, numbers, and _ only"))
    | Some(_) => setUnameValdnError(_ => None)
    }
    None
  }, [formUsername])

  React.useEffect(() => {
    switch (emailValdnError, unameValdnError) {
    | (None, None) => setValidationError(_ => false)
    | _ => setValidationError(_ => true)
    }
    None
  }, (emailValdnError, unameValdnError))

  {
    formUsername,
    formEmail,
    formSubmitClicked,
    validationError,
    emailValdnError,
    unameValdnError,
    setFormUsername,
    setFormEmail,
    setFormSubmitClicked,
    setValidationError,
    setEmailValdnError,
    setUnameValdnError,
  }
}
