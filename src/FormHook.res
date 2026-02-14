let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
let unameRegex = /^\w{3,10}$/

type return = {
  username: string,
  email: string,
  submitClicked: bool,
  validationError: bool,
  emailValdnError: option<string>,
  unameValdnError: option<string>,
  setUsername: (string => string) => unit,
  setEmail: (string => string) => unit,
  setSubmitClicked: (bool => bool) => unit,
  setValidationError: (bool => bool) => unit,
  setEmailValdnError: (option<string> => option<string>) => unit,
  setUnameValdnError: (option<string> => option<string>) => unit,
}

let useForm = () => {
  let (username, setUsername) = React.useState(_ => "")
  let (email, setEmail) = React.useState(_ => "")

  let (submitClicked, setSubmitClicked) = React.Uncurried.useState(_ => false)

  let (validationError, setValidationError) = React.useState(_ => true)

  let (emailValdnError, setEmailValdnError) = React.useState(_ => Some(
    "enter a valid email address",
  ))

  let (unameValdnError, setUnameValdnError) = React.useState(_ => Some(
    "3-10 letters, numbers, and _ only",
  ))

  React.useEffect(() => {
    Console.log("email error")
    switch String.match(email, emailRegex) {
    | None => setEmailValdnError(_ => Some("enter a valid email address"))
    | Some(_) => setEmailValdnError(_ => None)
    }
    None
  }, [email])

  React.useEffect(() => {
    Console.log("uname error")
    switch String.match(username, unameRegex) {
    | None => setUnameValdnError(_ => Some("3-10 letters, numbers, and _ only"))
    | Some(_) => setUnameValdnError(_ => None)
    }
    None
  }, [username])

  React.useEffect(() => {
    switch (emailValdnError, unameValdnError) {
    | (None, None) => setValidationError(_ => false)
    | _ => setValidationError(_ => true)
    }
    None
  }, (emailValdnError, unameValdnError))

  {
    username,
    email,
    submitClicked,
    validationError,
    emailValdnError,
    unameValdnError,
    setUsername,
    setEmail,
    setSubmitClicked,
    setValidationError,
    setEmailValdnError,
    setUnameValdnError,
  }
}
