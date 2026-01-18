let username_max_length = 10
let email_max_length = 99
let name_cookie_key = "clean_tablet_username="

@val @scope(("import", "meta", "env"))
external apikey: string = "VITE_SB_PUB_APIKEY"
@val @scope(("import", "meta", "env"))
external url: string = "VITE_SB_URL"

let options: Supabase.Options.t = {
  auth: {
    autoRefreshToken: true,
    storageKey: "my-custom-storage-key",
    persistSession: true,
    detectSessionInUrl: false,
  },
  // global: {
  //   headers: Dict.fromArray([("x-my-custom-header", "my-app-v1")]),
  // },
}
let client: Supabase.Client.t<unit> = Supabase.createClient(url, apikey, ~options)

@react.component
let make = () => {
  let (username, setUsername) = React.useState(_ => "")
  let (email, setEmail) = React.useState(_ => "")
  let (hasNameCookie, setHasNameCookie) = React.useState(_ => false)
  let (authError, setAuthError) = React.useState(_ => None)
  let (_validationError, setValidationError) = React.useState(_ => Some(
    "USERNAME: 3-10 length; EMAIL: 5-99 length; enter a valid email address.",
  ))

  React.useEffect(() => {
    ErrorHook.useMultiError([(username, Username), (email, Email)], setValidationError)
    None
  }, (username, email))

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

    // if (isCookieSet(nameCookieKey)) {
    //   console.log('cookie');
    //   setPlayerName(getCookieValue(nameCookieKey));
    // } else {
    //   console.log('no cookie');
    // }
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
    Console.log("submit clckd")
    // Route.push(SignIn)
    let {error} = await client
    ->Supabase.Client.auth
    ->Supabase.Auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: "http://localhost:5173/api/landing",
        shouldCreateUser: false,
        data: JSON.Encode.object(dict{"name": JSON.Encode.string(username)}),
      },
    })
    switch Nullable.toOption(error) {
    | Some(err) => Console.error(err)

    | None => Console.log("Check your email for the login link!")
    }
  }
  <>
    <Header />
    // ht="h-[35vh]"
    <Form on_Click leg="Sign in" validationError=None>
      {switch hasNameCookie {
      | true => React.null
      | false => <Input value=username propName="username" setFunc=setUsername />
      }}

      <Input value=email propName="email" inputMode="email" setFunc=setEmail />
    </Form>
    <Footer />
  </>
}
