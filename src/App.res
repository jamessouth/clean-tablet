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

let mockuser: Supabase.Auth.user = {
  id: "12345",
  email: "a@aol.com",
  user_metadata: {
    username: "bill",
    game: Some("123"),
    token: Some("123ef2"),
  },
}

@react.component
let make = () => {
  let route = Route.useRouter()

  let (hasAuth, setHasAuth) = React.useState(_ => None)

  //   let (_wsError, _setWsError) = React.Uncurried.useState(_ => "")
  //   let (_leaderData, _setLeaderData) = React.Uncurried.useState(_ => [])

  //   module LazyMessage = {
  //     let make = React.lazy_(() => import(Message.make))
  //   }
  Console.log2("app", hasAuth)

  module LazyLeaderboard = {
    let _make = React.lazy_(() => import(Leaderboard.make))
  }

  <main>
    {switch (route, hasAuth) {
    | (Home, None) =>
      //   open Route
      //   Web.body(Web.document)->Web.setClassName("lobbymob lobbytab lobbybig")

      <Home client setHasAuth />

    | (Home, Some(_)) => {
        Route.replace(Landing)
        React.null
      }

    | (SignIn(votp), None) => {
        Web.body(Web.document)
        ->Web.classList
        ->Web.addClassList3("landingmob", "landingtab", "landingbig")

        <SignIn setHasAuth client votp />
      }

    | (SignIn(_), Some(_)) => {
        Route.replace(Landing)
        React.null
      }

    | (Landing, None) =>
      Route.replace(Home)
      React.null

    | (Landing, Some(user)) =>
      Web.body(Web.document)
      ->Web.classList
      ->Web.addClassList3("landingmob", "landingtab", "landingbig")
      <Landing user client setHasAuth />

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

    | (Lobby, Some(user)) => <Lobby user client />

    | (Play(_), None) =>
      Route.replace(Home)
      React.null
    | (Play(_), Some(_)) =>
      <p className="font-flow text-stone-100 text-3xl "> {React.string("TODO 2")} </p>

    | (NotFound, _) =>
      <div>
        <Header />
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
}
