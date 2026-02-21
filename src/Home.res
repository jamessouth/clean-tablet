// let username_max_length = 10
// let email_max_length = 99

@react.component
let make = (~client, ~setHasAuth, ~nameCookieState, ~setNameCookie) => {
  let {
    formUsername,
    formEmail,
    formSubmitClicked,
    validationError,
    emailValdnError,
    unameValdnError,
    setFormUsername,
    setFormEmail,
    setFormSubmitClicked,
  } = FormHook.useForm()

  let (showToast, setShowToast) = ToastHook.useToast()

  let (loginstate, setLoginState) = React.useState(_ => Supabase.Global.Loading)
  let (showLoginStatus, setShowLoginStatus) = React.Uncurried.useState(_ => false)

  //   let (authError, setAuthError) = React.useState(_ => None)

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    Console.log2("cook", nameCookieState)
    switch (ignoreUpdate.contents, nameCookieState) {
    | (false, Some(c)) => setFormUsername(_ => c)
    | _ => ()
    }

    Some(() => ignoreUpdate.contents = true)
  }, [nameCookieState])

  React.useEffect(() => {
    let ignoreUpdate = ref(false)
    switch ignoreUpdate.contents {
    | true => ()
    | false => setShowToast(_ => Loading)
    }
    Console.log("in home eff")
    open Supabase
    let funfun = async () => {
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
        setShowToast(_ => Some(""))
      }
    }
    funfun()->ignore

    let {data: {subscription: {unsubscribe}}} =
      client
      ->Client.auth
      ->Auth.onAuthStateChange((ev, sess) => {
        Console.log3("auth event cb", ev, sess)
      })

    Some(
      () => {
        ignoreUpdate.contents = true
        unsubscribe()
      },
    )
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
    Console.log3("submit clckd", formUsername, formEmail)
    switch nameCookieState {
    | Some(_) => ()
    | None => setNameCookie(formUsername)
    }
    setShowLoginStatus(_ => true)
    // Route.push(SignIn)
    let {error} = await client
    ->Client.auth
    ->Auth.signInWithOtp({
      email: formEmail,
      options: {
        shouldCreateUser: true,
        data: JSON.Encode.object(dict{"username": JSON.Encode.string(formUsername)}),
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
    {switch showToast {
    | Loading => <Loading />
    | _ => React.null
    }}

    {switch (showLoginStatus, loginstate) {
    | (_, Error(err)) => <SupaErr err />
    | (true, Loading) => <Loading />
    | (true, Success()) =>
      <p className="text-stone-100 mx-auto text-xl font-anon w-4/5 text-center mb-[5vh]">
        {React.string("Click the link in your email to login!")}
      </p>
    | (false, _) =>
      <Form
        ht={switch nameCookieState {
        | Some(_) => "h-46"
        | None => "h-54"
        }}
        on_Click
        leg="Sign in"
        validationError
        setFormSubmitClicked
      >
        {switch nameCookieState {
        | Some(_) => React.null
        | None =>
          <Input
            value=formUsername
            propName="username"
            inputMode="username"
            setFunc=setFormUsername
            formSubmitClicked
            valdnError=unameValdnError
          />
        }}

        <Input
          value=formEmail
          propName="email"
          inputMode="email"
          setFunc=setFormEmail
          formSubmitClicked
          valdnError=emailValdnError
        />
      </Form>
    }}
  </>
}
