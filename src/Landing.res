let landingLinkStyles = "w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

@react.component
let make = (~user, ~client, ~setHasAuth, ~setUser) => {
  let onSignOutClick = async () => {
    Console.log("sinout clckd")

    // setHasAuth(_ => false)
    // setUser(_ => None)
    // // Route.push(SignIn)

    // let error = await client
    // ->Supabase.Client.auth
    // ->Supabase.Auth.signOut()

    // switch Nullable.toOption(error) {
    // | Some(err) =>
    //   Console.log2("err", err)
    //   setLoginState(_ => Error(err))

    // | None =>
    //   Console.log("Check your email for the login link!")
    //   setLoginState(_ => Success)
    // }
  }
  let onNameChangeClick = async () => {
    Console.log("ch name clckd")
  }

  let onEmailChangeClick = async () => {
    Console.log("ch email clckd")
  }

  <>
    <Menu onSignOutClick onNameChangeClick onEmailChangeClick />
    <p
      className="font-flow text-stone-100 text-3xl tracking-wide absolute top-0 left-1/2 -translate-x-1/2 font-bold "
    >
      {React.string(user)}
    </p>
    <Header mgt="mt-17" />
    <nav className="flex flex-col items-center h-[30vh] justify-around">
      <Link route=Lobby className={landingLinkStyles ++ "text-4xl"} content="LOBBY" />
      <Link route=Leaderboard className={landingLinkStyles ++ "text-3xl"} content="LEADERBOARD" />
    </nav>
  </>
}
