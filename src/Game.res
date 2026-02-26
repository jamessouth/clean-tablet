let btnStyle = " cursor-pointer text-base font-bold text-stone-100 font-anon w-1/2 bottom-0 h-8 absolute bg-stone-700 bg-opacity-70 filter disabled:(cursor-not-allowed contrast-25)"

@react.component
let make = (~client, ~game: Supabase.Game.game) => {
  let {id} = game
  let gamename = "Game no. " ++ Int.toString(id)

  let (status, sendToChan) = BroadcastHook.useBroadcast(
    ~client,
    ~config={
      broadcast: {self: true, ack: true},
      private_: true,
    },
    ~channelName="Chan " ++ gamename,
    ~event="*",
    ~onMessage=pl => Console.log2("onBC", pl),
  )

  <li
    className={"grid grid-cols-2 grid-rows-6 relative text-xl bg-bottom bg-no-repeat h-[200px] text-center font-bold text-dark-800 font-anon mb-12 lg:max-w-lg lg:w-full " ++
    "game" ++
    Int.toString(Int.mod(id, 10))}
  >
    <p className="text-shadow-[1px_2px_1px_rgba(28,25,23,1)] text-stone-100 text-sm ">
      {React.string(gamename)}
    </p>
    <p className="col-span-2" />

    <Button
      onClick={_ => {
        Console.log("game btn")
        sendToChan("hello")->ignore
      }}
      css=""
      className={"left-0 " ++ btnStyle}
    >
      {React.string("join")}
    </Button>
  </li>
}
