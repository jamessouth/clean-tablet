@react.component
let make = (~client, ~game: Supabase.Game.game, ~username) => {
  let {id} = game
  let gamename = "game no. " ++ Int.toString(id)
  let (players, setPlayers) = React.useState(_ => [
    "bill",
    "elizabeth",
    "andrew",
    "steve",
    "killroy",
    "adam",
    "dave",
    "longstocking",
    "rod",
    "paddy",
    "lisa",
    "william",
    "ulysses",
    "tom",
    "donnie",
    "charles",
  ])
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

  <li
    className={"bg-bottom bg-no-repeat flex flex-col justify-end items-center h-50 mb-12 mx-auto max-w-128 " ++
    "game" ++
    Int.toString(Int.mod(id, 10))}
  >
    <div className="flex w-5/6 flex-wrap max-w-75">
      {Array.mapWithIndex(players, (pl, i) => {
        <p
          className="grow font-arch text-lg tracking-wider text-stone-800 text-center px-1.5"
          key={Int.toString(i)}
        >
          {React.string(pl)}
        </p>
      })->React.array}
    </div>

    // let btnStyle = " cursor-pointer text-base   w-1/2     disabled:(cursor-not-allowed contrast-25)"

    <div
      className="flex h-8 font-bold text-stone-100 font-anon bg-stone-800/50 w-full items-center"
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
