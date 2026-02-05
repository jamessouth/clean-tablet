%%raw("import './css/lobby.css'")

@react.component
let make = (~user: Supabase.Auth.user) => {
  let {username} = user.user_metadata

  // <Loading label="games..." />
  <>
    <p
      className="font-flow text-stone-800 text-3xl tracking-wide absolute top-0 left-1/2 -translate-x-1/2 font-bold "
    >
      {React.string(username)}
    </p>
    <h2 className="text-center text-stone-800 text-5xl mt-28 font-fred">
      {React.string("LOBBY")}
    </h2>
    <button
      className="w-15 h-7 border bg-stone-800/5 border-stone-800 absolute top-0 left-0 cursor-pointer"
      onClick={_ => Route.push(Landing)}
    >
      <p className="text-2xl"> {React.string("⬅")} </p>
    </button>
    <div className="flex flex-col items-center">
      // <ul
      //   className="m-12 newgmimg:mt-14 w-11/12 <md:(flex max-w-lg flex-col) md:(grid grid-cols-2 gap-8) lg:(gap-10 justify-items-center) xl:(grid-cols-3 gap-12 max-w-1688px)"
      // >
      //   {gs
      //   ->Js.Array2.map(game => {
      //     let class = "game" ++ Js.String2.sliceToEnd(game.no, ~from=18)
      //     <Game
      //       key=game.no
      //       game
      //       inThisGame={playerListGame == game.no}
      //       inAGame={playerListGame != ""}
      //       count
      //       send
      //       class
      //       isOnlyGame={Js.Array2.length(gs) == 1}
      //     />
      //   })
      //   ->React.array}
      // </ul>
    </div>
  </>
}
