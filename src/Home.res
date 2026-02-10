// let username_max_length = 10
// let email_max_length = 99

@react.component
let make = (~client, ~setHasAuth) => {
  let {
    username,
    setUsername,
    email,
    setEmail,
    submitClicked,
    setSubmitClicked,
    validationError,
    emailValdnError,
    unameValdnError,
  } = FormHook.useForm()

  let {hasNameCookie, setHasNameCookie} = CookieHook.useCookie()

  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)
  let (showLoginStatus, setShowLoginStatus) = React.Uncurried.useState(_ => false)

  //   let (authError, setAuthError) = React.useState(_ => None)

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    switch (ignoreUpdate.contents, name_cookie_key->Cookie.getCookieValue) {
    | (true, _) => ()
    | (false, Some(v)) =>
      switch v->String.split("=")->Array.get(1) {
      | Some(c) =>
        setUsername(_ => c)
        setHasNameCookie(_ => true)
      | None => ()
      }
    | (false, None) => ()
    }
    Some(() => ignoreUpdate.contents = true)
  }, [])

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    Console.log("in home eff")
    let funfun = async () => {
      open Supabase
      Console.log("in home func")
      let {error, data} = await client
      ->Client.auth
      ->Auth.getSession

      Console.log3("home", error, data)

      switch (ignoreUpdate.contents, error, data) {
      | (true, _, _) => ()
      | (false, Value(err), _) =>
        setHasAuth(_ => None)
        setLoginState(_ => SupaError.Auth(err)->Error)
      | (false, _, {session: Value({user})}) => setHasAuth(_ => Some(user))
      | (false, _, _) =>
        setHasAuth(_ => None)
        setLoginState(_ => SupaError.authError->Error)
      }
    }

    funfun()->ignore

    Some(() => ignoreUpdate.contents = true)
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
      setLoginState(_ => SupaError.Auth(err)->Error)

    | None =>
      Console.log("Check your email for the login link!")
      setLoginState(_ => Success())
    }
  }
  <>
    <Header
      mgt={switch hasNameCookie {
      | true => "mt-20"
      | false => "mt-17"
      }}
      username={switch hasNameCookie {
      | true => username
      | false => ""
      }}
    />

    {switch showLoginStatus {
    | true =>
      switch loginstate {
      | Loading => <Loading />
      | Error(err) => <SupaErrToast err />
      | Success() =>
        <p className="text-stone-100 mx-auto text-xl font-anon w-4/5 text-center mb-[5vh]">
          {React.string("Click the link in your email to login!")}
        </p>
      }
    | false =>
      <Form
        ht={switch hasNameCookie {
        | true => "h-46"
        | false => "h-54"
        }}
        on_Click
        leg="Sign in"
        validationError
        setSubmitClicked
      >
        {switch hasNameCookie {
        | true => React.null
        | false =>
          <Input
            value=username
            propName="username"
            inputMode="username"
            setFunc=setUsername
            submitClicked
            valdnError=unameValdnError
          />
        }}

        <Input
          value=email
          propName="email"
          inputMode="email"
          setFunc=setEmail
          submitClicked
          valdnError=emailValdnError
        />
      </Form>
    }}

    <Footer />
  </>
}
