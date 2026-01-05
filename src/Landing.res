let landingLinkStyles = "w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

@react.component
let make = (~user) => {
  <>
    <Header />
    <p className="text-stone-100 text-center"> {React.string("Hello, " ++ user)} </p>
    <nav className="flex flex-col items-center h-[30vh] justify-around">
      <Link route=Lobby className={landingLinkStyles ++ "text-4xl"} content="LOBBY" />
      <Link route=Leaderboard className={landingLinkStyles ++ "text-3xl"} content="LEADERBOARD" />
    </nav>
  </>
}
