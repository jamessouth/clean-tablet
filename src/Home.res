// let username_max_length = 10
// let email_max_length = 99
type formType = SignIn | SignUp
type pageState<'data> =
  | Buttons
  | Form(formType)
  | Loading
  | Error(Supabase.SupaError.t)
  | Success('data)

@react.component
let make = (~client, ~setHasAuth) => {
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

  let (pageState, setPageState) = React.Uncurried.useState(_ => Buttons)

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
        setPageState(_ => SupaError.Auth(err)->Error)
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

    setPageState(_ => Loading)
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
      setPageState(_ => SupaError.Auth(err)->Error)

    | None =>
      Console.log("Check your email for the login link!")
      setPageState(_ => Success())
    }
  }
  <>
    {switch showToast {
    | Loading => <Loading />
    | _ => React.null
    }}

    {switch pageState {
    | Buttons =>
      <>
        <Button onClick={_ => f()->ignore} css="bg-stone-300 mr-5 ">
          {React.string("sign in")}
        </Button>
        <Button
          onClick={_ => {
            setFormSubmitClicked(_ => true)
          }}
        >
          {React.string("sign up")}
        </Button>
      </>

    | Form(tp) =>
      <Form
        ht={switch tp {
        | SignIn => "h-46"
        | SignUp => "h-54"
        }}
        on_Click
        leg={switch tp {
        | SignIn => "Sign in"
        | SignUp => "Sign up"
        }}
        validationError
        setFormSubmitClicked
      >
        {switch tp {
        | SignIn => React.null
        | SignUp =>
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
    | Error(err) => <SupaErr err />
    | Loading => <Loading />

    | Success() =>
      <p className="text-stone-100 mx-auto text-xl font-anon w-4/5 text-center mb-[5vh]">
        {React.string("Click the link in your email to login!")}
      </p>
    }}
  </>
}
