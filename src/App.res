@val @scope(("import", "meta", "env"))
external apikey: string = "VITE_SB_PUB_APIKEY"
@val @scope(("import", "meta", "env"))
external url: string = "VITE_SB_URL"
@send external setTime: (Date.t, Date.msSinceEpoch) => Date.t = "setTime"
let yearsMillis = Float.parseFloat("31536000000")
let name_cookie_key = "clean_tablet_username="

let setNameCookie = value => {
  let now = Date.make()
  let inAYear = Date.getTime(now) + yearsMillis
  let _ = now->setTime(inAYear)
  let expiry = now->Date.toUTCString

  Web.document->Web.setCookie(`${name_cookie_key}${value};expires=${expiry};path=/;SameSite=Strict`)
}

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

@react.component
let make = () => {
  let route = Route.useRouter()

  let (hasAuth, setHasAuth) = React.useState(_ => None)
  let (nameCookieState, setNameCookieState) = React.useState(_ => None)

  React.useEffect(() => {
    Console.log("in cookie eff")

    switch Web.cookie
    ->String.split(";")
    ->Array.find(k => k->String.trim->String.startsWith(name_cookie_key)) {
    | None => ()
    | Some(c) =>
      switch c->String.split("=")->Array.get(1) {
      | None => ()
      | Some(v) => setNameCookieState(_ => Some(v))
      }
    }

    None
  }, [])

  //   let (_wsError, _setWsError) = React.Uncurried.useState(_ => "")
  //   let (_leaderData, _setLeaderData) = React.Uncurried.useState(_ => [])

  //   module LazyMessage = {
  //     let make = React.lazy_(() => import(Message.make))
  //   }
  Console.log2("app", hasAuth)

  //   module LazyLeaderboard = {
  //     let _make = React.lazy_(() => import(Leaderboard.make))
  //   }

  <>
    <main>
      {switch (route, hasAuth) {
      | (Home, None) =>
        Web.document->Web.body->Web.setClassName("homemob hometab homebig")
        <>
          <Header
            mgt={switch nameCookieState {
            | Some(_) => "mt-20"
            | None => "mt-17"
            }}
            username=nameCookieState
          />
          <Home client setHasAuth nameCookieState setNameCookie />
        </>

      | (Home, Some(_)) => {
          Route.replace(Landing)
          React.null
        }

      | (SignIn(votp), None) => {
          Web.document->Web.body->Web.setClassName("landingmob landingtab landingbig")
          <>
            <Header />
            <SignIn setHasAuth client votp />
          </>
        }

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
        <>
          <Header username=nameCookieState />
          <Landing user client setHasAuth setNameCookie />
        </>

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

      | (Lobby, Some(user)) =>
        <>
          <Header username=nameCookieState head=false />
          <Lobby user client />
        </>

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
