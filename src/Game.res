// let btnStyle = " cursor-pointer text-base font-bold text-stone-100 font-anon w-1/2 bottom-0 h-8 absolute bg-stone-700 bg-opacity-70 filter disabled:(cursor-not-allowed contrast-25)"

// @react.component
// let make = (~game, ~inThisGame, ~inAGame, ~count, ~send, ~class, ~isOnlyGame) => {
//   let liStyle = `<md:mb-16 grid grid-cols-2 grid-rows-6 relative text-xl bg-bottom bg-no-repeat h-200px text-center font-bold text-dark-800 font-anon pb-8 ${class} lg:(max-w-lg w-full)`
//   let (disabledJoin, setDisabledJoin) = React.Uncurried.useState(_ => false)
//   let {no, timerCxld, players}: Reducer.listGame = game

//   let onClickJoin = _ => {
//     send(
//       payloadToObj({
//         act: Lobby,
//         gn: no,
//         cmd: switch inThisGame {
//         | true => Leave
//         | false => Join
//         },
//       }),
//     )
//   }

//   React.useEffect3(() => {
//     let size = Js.Array2.length(players)
//     switch (inThisGame, inAGame) {
//     | (true, _) => setDisabledJoin(_ => false) //in this game
//     | (false, true) => setDisabledJoin(_ => true) //in another game
//     | (_, false) =>
//       setDisabledJoin(_ =>
//         if size > players_max_threshold {
//           true
//         } else {
//           false
//         }
//       ) //not in a game
//     }
//     None
//   }, (inThisGame, inAGame, players))

//   React.useEffect3(() => {
//     switch inThisGame && count == "start" {
//     | true => Route.push(Auth({subroute: Play({play: no})}))
//     | false => ()
//     }
//     None
//   }, (inThisGame, count, no))

//   <li
//     className={switch (inThisGame, isOnlyGame) {
//     | (true, false) => "shadow-lg shadow-stone-100 " ++ liStyle
//     | (false, true) | (true, true) | (false, false) => liStyle
//     }}
//   >
//     <p className="absolute text-stone-100 text-xs left-1/2 transform -translate-x-2/4 -top-3.5">
//       {React.string(no)}
//     </p>
//     <p className="col-span-2" />
//     {players
//     ->Js.Array2.mapi((p, i) => {
//       <p key={j`${p.name}$i`}> {React.string(p.name)} </p>
//     })
//     ->React.array}
//     {switch (timerCxld, inThisGame) {
//     | (false, false) =>
//       <p
//         className="absolute text-2xl animate-pulse font-perm left-1/2 top-2/3 transform -translate-x-2/4 w-full"
//       >
//         {React.string("Starting soon...")}
//       </p>
//     | (false, true) =>
//       <p
//         className="absolute text-4xl animate-ping1 font-perm left-1/2 top-1/4 transform -translate-x-2/4"
//       >
//         {React.string(count)}
//       </p>
//     | (true, false) | (true, true) => React.null
//     }}
//     <Button onClick=onClickJoin disabled=disabledJoin className={"left-0" ++ btnStyle}>
//       {switch inThisGame {
//       | true => React.string("leave")
//       | false => React.string("join")
//       }}
//     </Button>
//   </li>
// }

