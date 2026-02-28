@react.component
let make = (~client, ~game: Supabase.Game.game, ~username) => {
  let {id} = game
  let gamename = "game no. " ++ Int.toString(id)
  let (players, setPlayers) = React.useState(_ => [])
  let noPlrs = Array.length(players)

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

  // parent
  // display: flex;
  //   flex-wrap: wrap;
  //   gap: 12px;
  //   padding: 20px;
  //   background: #a4c8bb;
  //   border-radius: 8px;

  // child
  // flex-grow: 1;
  //   flex-basis: auto;
  //   text-align: center;
  //   padding: 10px 20px;
  //   background: #16213e;
  //   color: #e94560;
  //   border: 2px solid #e94560;
  //   border-radius: 50px;
  //   font-family: 'Segoe UI', sans-serif;
  //   font-weight: bold;
  //   font-size: 1.1rem;
  //   max-width: 300px;

  <li
    className={"relative bg-bottom bg-no-repeat h-[200px] text-dark-800 mb-12 lg:max-w-lg lg:w-full " ++
    "game" ++
    Int.toString(Int.mod(id, 10))}
  >
    <div className="flex w-5/6 h-42 justify-around flex-wrap m-auto">
      {Array.mapWithIndex(players, (pl, i) => {
        <p className="" key={Int.toString(i)}> {React.string(pl)} </p>
      })->React.array}
    </div>

    // let btnStyle = " cursor-pointer text-base   w-1/2     disabled:(cursor-not-allowed contrast-25)"

    <div
      className="flex absolute bottom-0 h-8 font-bold text-stone-100 font-anon bg-stone-800/50 w-full items-center"
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
        className="basis-[24%] h-full bg-stone-800/58 cursor-pointer"
      >
        {React.string("join")}
      </Button>
      <p className="basis-[26%] text-center px-[2px] text-xs sm:text-sm">
        {React.string(gamename)}
      </p>
      <p className="basis-[26%] text-center border-l border-stone-800 text-xs sm:text-sm">
        {React.string(
          `${Int.toString(noPlrs)} player` ++
          switch noPlrs {
          | 1 => ""
          | _ => "s"
          },
        )}
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
        className="basis-[24%] h-full bg-stone-800/58 cursor-pointer"
      >
        {React.string("leave")}
      </Button>
    </div>
  </li>
}
