let btnStyle = " cursor-pointer text-base font-bold text-stone-100 font-anon w-1/2 bottom-0 h-8 absolute bg-stone-700 bg-opacity-70 filter disabled:(cursor-not-allowed contrast-25)"

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
    <p
      className="text-shadow-[1px_2px_1px_rgba(28,25,23,1)] text-stone-100 text-center font-anon font-bold text-sm "
    >
      {React.string(gamename)}
    </p>
    <ul>
      {Array.mapWithIndex(players, (pl, i) => {
        <li key={Int.toString(i)}> {React.string(pl)} </li>
      })->React.array}
    </ul>
    <Button
      onClick={_ => {
        Console.log("join btn")
        switch channelRef.current {
        | Value(ch) => ch->Supabase.Realtime.sendBroadcast(~event="join", ~payload=username)->ignore
        | _ => ()
        }
      }}
      css=""
      className={"left-0 " ++ btnStyle}
    >
      {React.string("join")}
    </Button>
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
      className={"right-0 " ++ btnStyle}
    >
      {React.string("leave")}
    </Button>
  </li>
}
