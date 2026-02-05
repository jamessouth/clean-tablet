let homeLinkStyles = "w-3/5 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

@val @scope(("import", "meta", "env"))
external apikey: string = "VITE_SB_PUB_APIKEY"
@val @scope(("import", "meta", "env"))
external url: string = "VITE_SB_URL"

let options: Supabase.Options.t = {
  auth: {
    autoRefreshToken: true,
    storageKey: "my-custom-storage-key",
    persistSession: true,
    detectSessionInUrl: true,
    // flowType: PKCE,
  },
  // global: {
  //   headers: Dict.fromArray([("x-my-custom-header", "my-app-v1")]),
  // },
}
let client: Supabase.Client.t<unit> = Supabase.Global.createClient(url, apikey, ~options)

@react.component
let make = () => {
  let route = Route.useRouter() //TODO don't pass down to auth

  let (user, setUser) = React.useState(_ => None)
  let (hasAuth, setHasAuth) = React.useState(_ => false)

  //   let (token, _setToken) = React.Uncurried.useState(_ => None)
  //   let (retrievedUsername, setRetrievedUsername) = React.Uncurried.useState(_ => "")
  let (_wsError, _setWsError) = React.Uncurried.useState(_ => "")
  let (_leaderData, _setLeaderData) = React.Uncurried.useState(_ => [])

  //   module LazyMessage = {
  //     let make = React.lazy_(() => import(Message.make))
  //   }
  Console.log3("pp", hasAuth, user)

  module LazyLeaderboard = {
    let _make = React.lazy_(() => import(Leaderboard.make))
  }

  //   let auth = React.createElement(
  //     Auth.lazy_(() =>
  //       Auth.import_("./Auth.bs")->Promise.then(comp => {
  //         Promise.resolve({"default": comp["make"]})
  //       })
  //     ),
  //     Auth.makeProps(~token, ~setToken, ~cognitoUser, ~setCognitoUser, ~setWsError, ~route, ()),
  //   )

  <main
  // className={switch route {
  // | Leaderboard => ""
  // | _ => "mb-12"
  // }}
  >
    {switch (route, hasAuth) {
    | (Home, false) => {
        //   open Route
        // Web.body(Web.document)->Web.setClassName("bodmob bodtab bodbig")

        Web.body(Web.document)
        ->Web.classList
        ->Web.addClassList3("landingmob", "landingtab", "landingbig")
        //   <nav className="flex flex-col items-center">
        //     <Link route=SignIn className={homeLinkStyles ++ "text-3xl"} content="SIGN IN" />
        //     {switch wsError == "" {
        //     | true => React.null
        //     | false =>
        //       <React.Suspense fallback=React.null>
        //         <LazyMessage msg=wsError />
        //       </React.Suspense>
        //     }}
        //   </nav>
        <Home client />
        // <Landing user="pok" client setHasAuth setUser />
      }

    | (Auth_Confirm(votp), _) => <SignIn setHasAuth setUser client votp />

    // | (Leaderboard, _) =>
    //   <React.Suspense fallback=React.null>
    //     <LazyLeaderboard playerName="bill" setLeaderData />
    //   </React.Suspense>

    // | (SignIn, false) => <SignIn hasAuth setHasAuth setUser user />
    | (SignIn, false) => <div> {React.string("uuu")} </div>

    | (Lobby, false) => <Lobby />

    | (Landing, false) =>
      Route.replace(Home)
      React.null

    | (Leaderboard | Play(_), false) => // Route.replace(Home)
      React.null

    | (Home | SignIn, true) => {
        Route.replace(Landing)
        React.null
      }

    | (Landing, true) =>
      switch user {
      | Some(user) => <Landing user client setHasAuth setUser />
      | None => <p className="font-flow text-stone-100 text-3xl "> {React.string("TODO")} </p>
      }

    | (Leaderboard | Lobby | Play(_), true) => React.null
    //   <React.Suspense fallback=React.null> auth </React.Suspense>
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
