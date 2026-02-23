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
      | (false, _, {session: Value({user})}) =>
        setShowToast(_ => None)
        setHasAuth(_ => Some(user))

      | (false, _, _) =>
        setHasAuth(_ => None)
        setShowToast(_ => None)
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
  // { TAG: "Form", _0: "SignUp" }
  let on_Click = async () => {
    open Supabase
    Console.log3("submit clckd", formUsername, formEmail)
    Console.log2("pgstate", pageState)
    let options: Auth.signInWithOtpOptions = switch pageState {
    | Form(tp) =>
      switch tp {
      | SignIn => {
          shouldCreateUser: false,
        }
      | SignUp => {
          shouldCreateUser: true,
          data: JSON.Encode.object(dict{"username": JSON.Encode.string(formUsername)}),
        }
      }
    | _ => {}
    }

    setPageState(_ => Loading)
    let {error} = await client
    ->Client.auth
    ->Auth.signInWithOtp({
      email: formEmail,
      options,
    })
    switch Nullable.toOption(error) {
    | Some(err) =>
      Console.log2("err", err)
      setPageState(_ => SupaError.Auth(err)->Error)

    | None =>
      Console.log("Check your email for the login link!")
      setPageState(_ => Success("You may close this tab."))
      setShowToast(_ => Some("Check your email for the magic link!"))
    }
  }
  <>
    {switch showToast {
    | Loading => <Loading />
    | Some(msg) => <Toast msg setShowToast />
    | None => React.null
    }}

    {switch pageState {
    | Buttons =>
      <div className="flex flex-col items-center h-[25vh] justify-around">
        <Button
          onClick={_ => {
            setFormUsername(_ => "ddd")
            setPageState(_ => Form(SignIn))
          }}
        >
          {React.string("SIGN IN")}
        </Button>
        <Button
          onClick={_ => {
            setPageState(_ => Form(SignUp))
          }}
        >
          {React.string("SIGN UP")}
        </Button>
      </div>

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
    | Success(m) =>
      switch showToast {
      | None =>
        <p className="text-stone-100 mx-auto text-xl font-anon w-4/5 text-center mb-[5vh]">
          {React.string(m)}
        </p>
      | _ => React.null
      }
    }}
  </>
}
