@react.component
let make = () => {
  // 1. Create the options object

  // 2. Initialize the client
  // We use 'unit' for the generic 'db type here as a placeholder

  let _onMessage = msg => {
    Console.log2("msg: ", msg)
  }

  //   let (status, bc) = BroadcastHook.useBroadcast(
  //     ~client,
  //     ~channelName="mychan1",
  //     ~event="myevent1",
  //     ~onMessage,
  //   )

  //   Console.log2(status, bc)

  <div> {React.string("ddd")} </div>
}
