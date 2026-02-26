@val @scope(("import", "meta", "env"))
external apikey: string = "VITE_SB_PUB_APIKEY"
@val @scope(("import", "meta", "env"))
external url: string = "VITE_SB_URL"

let options: Supabase.Options.t = {
  auth: {
    autoRefreshToken: true,
    storageKey: "clean-tablet",
    persistSession: true,
    detectSessionInUrl: true,
    // flowType: PKCE,
  },
  // global: {
  //   headers: Dict.fromArray([("x-my-custom-header", "my-app-v1")]),
  // },
}
let client: Supabase.Client.t<unit> = Supabase.Global.createClient(url, apikey, ~options)

// let mockuser: Supabase.Auth.user = {
//   id: "12345",
//   email: "a@aol.com",
//   user_metadata: {
//     username: "bill",
//     game: Some("123"),
//     token: Some("123ef2"),
//   },
// }

//   React.useEffect0(() => {
//     Js.log("signin use effect")

//     ImageLoad.import_("./ImageLoad.bs")
//     ->Promise.then(func => {
//       Promise.resolve(func["bghand"](.))
//     })
//     ->ignore

//     None
//   })

type formType = SignIn | SignUp
type pageState<'data> =
  | Buttons
  | Form(formType)
  | Loading
  | Error(Supabase.SupaError.t)
  | Success('data)

let ranOnce = ref(false)

@react.component
let make = () => {
  let route = Route.useRouter()
  let (showToast, setShowToast) = ToastHook.useToast()
  let (pageState, setPageState) = React.Uncurried.useState(_ => Loading)
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

  let (hasAuth, setHasAuth) = React.useState(_ => None)
  let (username, setUsername) = React.useState(_ => None)

  let getName = async id => {
    Console.log("app func")
    let (_, signal) = AbortCtrl.abortCtrl("App getName")
    open Supabase
    let {status, statusText, data, error, count} = await client
    ->Client.from("profiles")
    ->DB.select("username")
    ->DB.abortSignal(signal)
    ->DB.eq("id", id)
    ->DB.single

    Console.log6("app get name", status, statusText, data, error, count)

    switch (error, data, count, status, statusText) {
    | (Value(err), _, _, s, st) =>
      switch err.message->String.includes("FetchError: undefined") {
      | true => Console.log("eating abort err")
      | false => Console.log("some other err")
      }
      Console.log2(s, st)
      Console.error(err)
      setUsername(_ => Some("undefined"))
    | (_, Value({DB.username: username}), _, _, _) => setUsername(_ => Some(username))

    | (_, _, _, _, _) =>
      Console.log("no data or error on name fetch")
      setUsername(_ => Some("undefined"))
    }
  }

  React.useEffect(() => {
    open Supabase
    Console.log2("rano", ranOnce.contents)
    switch ranOnce.contents {
    | true => None
    | false => {
        ranOnce := true
        switch (route, hasAuth) {
        | (SignIn(votp), None) => {
            let signinfun = async () => {
              let {error, data} = await client
              ->Client.auth
              ->Auth.verifyOtp(votp)

              Console.log3("signin data", error, data)

              switch (error, data) {
              | (Value(err), _) =>
                setHasAuth(_ => None)
                setPageState(_ => SupaError.Auth(err)->Error)
              | (_, Value({user: Value(user)})) =>
                Route.replace(
                  SignIn({
                    type_: #other,
                    token_hash: "",
                  }),
                )
                await getName(user.id)
                setPageState(_ => Buttons)
                setHasAuth(_ => Some(user))
              | (_, _) =>
                setHasAuth(_ => None)
                setPageState(_ => SupaError.authError->Error)
              }
            }

            signinfun()->ignore
            None
          }
        | (_, None) => {
            Console.log("in home eff")

            let homefun = async () => {
              Console.log("in home func")
              let {error, data} = await client
              ->Client.auth
              ->Auth.getSession

              Console.log3("home", error, data)

              switch (error, data) {
              | (Value(err), _) =>
                setHasAuth(_ => None)
                setPageState(_ => SupaError.Auth(err)->Error)
              | (_, {session: Value({user})}) =>
                await getName(user.id)
                setPageState(_ => Buttons)
                setHasAuth(_ => Some(user))
              | (_, _) =>
                setHasAuth(_ => None)
                setPageState(_ => Buttons)
              }
            }
            homefun()->ignore

            let {data: {subscription: {unsubscribe}}} =
              client
              ->Client.auth
              ->Auth.onAuthStateChange((ev, sess) => {
                Console.log3("auth event cb", ev, sess)
              })

            Some(() => unsubscribe())
          }
        | _ => None
        }
      }
    }
  }, [hasAuth])

  //   module LazyMessage = {
  //     let make = React.lazy_(() => import(Message.make))
  //   }
  Console.log2("app", hasAuth)

  //   module LazyLeaderboard = {
  //     let _make = React.lazy_(() => import(Leaderboard.make))
  //   }

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
    {switch (route, hasAuth) {
    | (Home | SignIn(_), None) => <Header />
    | (Landing, Some(_)) => <Header username />
    | (Lobby, Some(_)) => <Header username head=false color="stone-800" />
    | _ => React.null
    }}
    <main>
      {switch (route, hasAuth) {
      | (Home, None) =>
        Web.document->Web.body->Web.setClassName("homemob hometab homebig")

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

      | (Home, Some(_)) => {
          Route.replace(Landing)
          React.null
        }

      | (SignIn(_), None) =>
        Web.document->Web.body->Web.setClassName("landingmob landingtab landingbig")

        <div>
          {switch pageState {
          | Loading => <Loading label="session" />
          | Error(err) => <SupaErr err />
          | _ => React.null
          }}
        </div>

      | (SignIn(_), Some(_)) => {
          Route.replace(Landing)
          React.null
        }

      | (About, None) =>
        Web.document->Web.body->Web.setClassName("aboutmob abouttab aboutbig")
        <About />
      | (About, Some(_)) => {
          Route.replace(Landing)
          React.null
        }

      | (Landing, None) =>
        Route.replace(Home)
        React.null

      | (Landing, Some(user)) =>
        Web.document->Web.body->Web.setClassName("landingmob landingtab landingbig")
        <Landing user client setHasAuth setUsername />

      // | (Leaderboard, _) =>
      //   <React.Suspense fallback=React.null>
      //     <LazyLeaderboard playerName="bill" setLeaderData />
      //   </React.Suspense>
      //   <React.Suspense fallback=React.null> auth </React.Suspense>

      | (Leaderboard, None) =>
        Route.replace(Home)
        React.null

      | (Leaderboard, Some(_)) =>
        <p className="font-flow text-stone-100 text-3xl "> {React.string("TODO 1")} </p>

      | (Lobby, None) =>
        Route.replace(Home)
        React.null

      | (Lobby, Some(_)) =>
        Web.document->Web.body->Web.setClassName("lobbymob lobbytab lobbybig")
        <Lobby username client />

      | (Play(_), None) =>
        Route.replace(Home)
        React.null
      | (Play(_), Some(_)) =>
        <p className="font-flow text-stone-100 text-3xl "> {React.string("TODO 2")} </p>

      | (NotFound, _) =>
        Web.document->Web.body->Web.setClassName("homemob hometab homebig")
        <div>
          <p className="text-center font-anon mt-12 mx-4 text-stone-100 text-4xl">
            {React.string("page not found")}
          </p>
          <Button
            onClick={_ => {
              Route.push(Home)
            }}
          >
            {React.string("home")}
          </Button>
        </div>
      }}
    </main>
    {switch route {
    | Home => <Footer />
    | _ => React.null
    }}
  </>
}
