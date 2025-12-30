let homeLinkStyles = "w-3/5 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

module Link = {
  open Route
  @react.component
  let make = (~route, ~className, ~content="") => {
    let onClick = e => {
      ReactEvent.Mouse.preventDefault(e)
      push(route)
    }

    <a onClick className href={typeToUrlString(route)}> {React.string(content)} </a>
  }
}

@react.component
let make = () => {
  let route = Route.useRouter() //TODO don't pass down to auth

  //   let (cognitoUser: Js.Nullable.t<Cognito.usr>, setCognitoUser) = React.Uncurried.useState(_ =>
  //     Js.Nullable.null
  //   )

  let (token, _setToken) = React.Uncurried.useState(_ => None)
  //   let (retrievedUsername, setRetrievedUsername) = React.Uncurried.useState(_ => "")
  let (_wsError, _setWsError) = React.Uncurried.useState(_ => "")
  let (_leaderData, setLeaderData) = React.Uncurried.useState(_ => [])

  //   module LazyMessage = {
  //     let make = React.lazy_(() => import(Message.make))
  //   }

  module LazyLeaderboard = {
    let make = React.lazy_(() => import(Leaderboard.make))
  }

  //   let auth = React.createElement(
  //     Auth.lazy_(() =>
  //       Auth.import_("./Auth.bs")->Promise.then(comp => {
  //         Promise.resolve({"default": comp["make"]})
  //       })
  //     ),
  //     Auth.makeProps(~token, ~setToken, ~cognitoUser, ~setCognitoUser, ~setWsError, ~route, ()),
  //   )

  <>
    {switch route {
    | Leaderboard => React.null
    | Home | SignIn | Auth(_) | NotFound =>
      switch token {
      | None =>
        <header className="mb-10 newgmimg:mb-12">
          <h1
            className="text-6xl mt-21 mx-auto px-6 text-center font-arch decay-mask text-stone-100"
          >
            {React.string("CLEAN TABLET")}
          </h1>
        </header>
      | Some(_) => React.null
      }
    }}
    <main
      className={switch route {
      | Leaderboard => ""
      | Home | SignIn | Auth(_) | NotFound => "mb-12"
      }}
    >
      {switch (route, token) {
      | (Home, None) => {
          //   open Route
          Web.body(Web.document)->Web.setClassName("bodmob bodtab bodbig")
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
          <Signin />
        }

      | (Leaderboard, _) =>
        <React.Suspense fallback=React.null>
          <LazyLeaderboard playerName="bill" setLeaderData />
        </React.Suspense>

      | (SignIn, _) =>
        <div>
          <p className="text-stone-100 text-center">
            {React.string("Click the link sent to your email to login.")}
          </p>
        </div>

      | (Auth(_), None) => {
          Route.replace(Home)
          React.null
        }

      | (Home, Some(_)) => {
          Route.replace(Auth({subroute: Lobby}))
          React.null
        }

      | (Auth(_), Some(_)) => React.null
      //   <React.Suspense fallback=React.null> auth </React.Suspense>
      | (NotFound, _) =>
        <div className="text-center text-stone-100 text-4xl">
          {React.string("page not found")}
        </div>
      }}
    </main>
    {switch (route, token) {
    | (Home, _) =>
      <footer className="mb-2">
        <a
          href="https://github.com/jamessouth/clean-tablet"
          className="w-7 h-7 block m-auto"
          rel="noopener noreferrer"
        >
          <svg
            className="w-7 h-7 fill-stone-100 absolute"
            viewBox="0 0 32 32"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M16 2a14 14 0 0 0-4.43 27.28c.7.13 1-.3 1-.67v-2.38c-3.89.84-4.71-1.88-4.71-1.88a3.71 3.71 0 0 0-1.62-2.05c-1.27-.86.1-.85.1-.85a2.94 2.94 0 0 1 2.14 1.45a3 3 0 0 0 4.08 1.16a2.93 2.93 0 0 1 .88-1.87c-3.1-.36-6.37-1.56-6.37-6.92a5.4 5.4 0 0 1 1.44-3.76a5 5 0 0 1 .14-3.7s1.17-.38 3.85 1.43a13.3 13.3 0 0 1 7 0c2.67-1.81 3.84-1.43 3.84-1.43a5 5 0 0 1 .14 3.7a5.4 5.4 0 0 1 1.44 3.76c0 5.38-3.27 6.56-6.39 6.91a3.33 3.33 0 0 1 .95 2.59v3.84c0 .46.25.81 1 .67A14 14 0 0 0 16 2Z"
            />
          </svg>
        </a>
      </footer>
    | _ => React.null
    }}
  </>
}
