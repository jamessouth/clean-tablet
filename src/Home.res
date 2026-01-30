// let username_max_length = 10
// let email_max_length = 99
let name_cookie_key = "clean_tablet_username="

let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
let unameRegex = /^\w{3,10}$/

@react.component
let make = (~client) => {
  let (loginstate, setLoginState) = React.useState(_ => Supabase.Auth.Loading)
  let (showLoginStatus, setShowLoginStatus) = React.Uncurried.useState(_ => false)

  let (username, setUsername) = React.useState(_ => "")
  let (email, setEmail) = React.useState(_ => "")
  let (hasNameCookie, setHasNameCookie) = React.useState(_ => false)
  //   let (authError, setAuthError) = React.useState(_ => None)
  let (submitClicked, setSubmitClicked) = React.Uncurried.useState(_ => false)

  let (validationError, setValidationError) = React.useState(_ => true)

  let (emailValdnError, setEmailValdnError) = React.useState(_ => Some(
    "enter a valid email address",
  ))

  let (unameValdnError, setUnameValdnError) = React.useState(_ => Some(
    "3-10 letters, numbers, and _ only",
  ))

  React.useEffect(() => {
    switch String.match(email, emailRegex) {
    | None => setEmailValdnError(_ => Some("enter a valid email address"))
    | Some(_) => setEmailValdnError(_ => None)
    }
    None
  }, [email])

  React.useEffect(() => {
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

  React.useEffect(() => {
    switch name_cookie_key->Cookie.getCookieValue {
    | Some(v) =>
      switch v->String.split("=")->Array.get(1) {
      | Some(c) =>
        setUsername(_ => c)
        setHasNameCookie(_ => true)
      | None => ()
      }
    | None => ()
    }
    None
  }, [])

  //   React.useEffect0(() => {
  //     Js.log("signin use effect")

  //     ImageLoad.import_("./ImageLoad.bs")
  //     ->Promise.then(func => {
  //       Promise.resolve(func["bghand"](.))
  //     })
  //     ->ignore

  //     None
  //   })

  let on_Click = async () => {
    open Supabase
    Console.log3("submit clckd", username, email)
    switch hasNameCookie {
    | true => ()
    | false => name_cookie_key->Cookie.setCookie(username)
    }
    setShowLoginStatus(_ => true)
    // Route.push(SignIn)
    let {error} = await client
    ->Client.auth
    ->Auth.signInWithOtp({
      email,
      options: {
        shouldCreateUser: true,
        data: JSON.Encode.object(dict{"username": JSON.Encode.string(username)}),
        
      },
    })
    switch Nullable.toOption(error) {
    | Some(err) =>
      Console.log2("err", err)
      setLoginState(_ => Error(err))

    | None =>
      Console.log("Check your email for the login link!")
      setLoginState(_ => Success)
    }
  }
  <>
    {switch hasNameCookie {
    | true =>
      <p
        className="font-flow text-stone-100 text-3xl tracking-wide absolute top-0 left-1/2 -translate-x-1/2 font-bold "
      >
        {React.string(`Hello, ${username}!`)}
      </p>
    | false => React.null
    }}

    <Header
      mgt={switch hasNameCookie {
      | true => "mt-20"
      | false => "mt-17"
      }}
    />

    {switch showLoginStatus {
    | true =>
      switch loginstate {
      | Loading => <Loading />
      | Error(err) => <SupaErr err />
      | Success =>
        <p className="text-stone-100 mx-auto text-xl font-anon w-4/5 text-center mb-[5vh]">
          {React.string("Click the link in your email to login!")}
        </p>
      }
    | false =>
     
     
    }}

    <Footer />
  </>
}
