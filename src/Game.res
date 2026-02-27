@react.component
let make = (~client, ~game: Supabase.Game.game, ~username) => {
  let {id} = game
  let gamename = "Game no. " ++ Int.toString(id)
  let (players, setPlayers) = React.useState(_ => [])

  let (_status, setStatus) = React.useState(_ => None)
  Console.log2("game", gamename)
  let channelRef = React.useRef(Nullable.null)
  React.useEffect(() => {
    let channel = client->Supabase.Client.channel(
      "Chan " ++ gamename,
      ~options={
        config: {
          broadcast: {self: true, ack: true},
          private_: true,
        },
      },
    )
    channelRef.current = Nullable.make(channel)
    // (prev => prev->Array.concat([res.payload])->Set.fromArray->Set.toArray)
    channel
    ->Supabase.Realtime.onBroadcast({"event": "join"}, res =>
      setPlayers(prev => prev->Array.concat([res.payload]))
    )
    ->Supabase.Realtime.onBroadcast({"event": "leave"}, res =>
      setPlayers(prev => prev->Array.filter(x => x !== res.payload))
    )
    ->Supabase.Realtime.subscribeWithCallback((newStatus, err) => {
      Console.log4("rtsub cb", gamename, newStatus, err)

      // In Strict Mode, this might fire for the first 'mount' even after unmount
      // Checking if channelRef is still set prevents setting state on unmounted components
      switch channelRef.current {
      | Value(_) => setStatus(_ => Some(newStatus))
      | _ => ()
      }
    })
    ->ignore

    // 4. Cleanup
    Some(
      () => {
        // Mark our local ref as null so we don't try to use it
        channelRef.current = Nullable.null

        // Tell Supabase to leave the channel.
        // Note: removeChannel is async, but we can't await it here.
        client->Supabase.Client.removeChannel(channel)->ignore
      },
    )
  }, [client])

  <li
    className={"relative bg-bottom bg-no-repeat h-[200px] text-dark-800 mb-12 lg:max-w-lg lg:w-full " ++
    "game" ++
    Int.toString(Int.mod(id, 10))}
  >
    <ul className="flex">
      {Array.mapWithIndex(players, (pl, i) => {
        <li key={Int.toString(i)}> {React.string(pl)} </li>
      })->React.array}
    </ul>

    // let btnStyle = " cursor-pointer text-base   w-1/2     disabled:(cursor-not-allowed contrast-25)"

    <div
      className="flex absolute bottom-0 h-8 font-bold text-stone-100 font-anon bg-stone-800/55 w-full items-center"
    >
      <Button
        onClick={_ => {
          Console.log("join btn")
          switch channelRef.current {
          | Value(ch) =>
            ch->Supabase.Realtime.sendBroadcast(~event="join", ~payload=username)->ignore
          | _ => ()
          }
        }}
        css=""
        className="basis-1/4 h-full cursor-pointer"
      >
        {React.string("join")}
      </Button>
      <p className="basis-1/4 text-center text-sm "> {React.string(gamename)} </p>
      <p className="basis-1/4 text-center text-sm ">
        {React.string(`${Int.toString(Array.length(players))} players`)}
      </p>
      <Button
        onClick={_ => {
          Console.log("leave btn2")
          switch channelRef.current {
          | Value(ch) =>
            ch->Supabase.Realtime.sendBroadcast(~event="leave", ~payload=username)->ignore
          | _ => ()
          }
        }}
        css=""
        className="basis-1/4 h-full cursor-pointer"
      >
        {React.string("leave")}
      </Button>
    </div>
  </li>
}
