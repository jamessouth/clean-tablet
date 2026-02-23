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

@react.component
let make = () => {
  let route = Route.useRouter()

  let (hasAuth, setHasAuth) = React.useState(_ => None)
  let (username, setUsername) = React.useState(_ => None)

  React.useEffect(() => {
    Console.log("app eff")

    open Supabase
    switch hasAuth {
    | None => None
    | Some({id}: Auth.user) => {
        let (controller, signal) = AbortCtrl.abortCtrl("App")

        let getUname = async () => {
          Console.log("app func")

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

        getUname->ignore

        Some(() => controller->Fetch.AbortController.abort(~reason="timeout or user abort"))
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

  <>
    {switch (route, hasAuth) {
    | (Home, None) => <Header />
    | (SignIn(_), None) => <Header />
    | (Landing, Some(_)) => <Header username />
    | (Lobby, Some(_)) => <Header username head=false />
    | _ => React.null
    }}
    <main>
      {switch (route, hasAuth) {
      | (Home, None) =>
        Web.document->Web.body->Web.setClassName("homemob hometab homebig")
        <Home client setHasAuth />

      | (Home, Some(_)) => {
          Route.replace(Landing)
          React.null
        }

      | (SignIn(votp), None) => {
          Web.document->Web.body->Web.setClassName("landingmob landingtab landingbig")
          <SignIn setHasAuth client votp />
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

      | (Lobby, Some(user)) => <Lobby user client />

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
