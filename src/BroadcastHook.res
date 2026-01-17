let useBroadcast = (~client, ~channelName, ~event, ~onMessage) => {
  let (status, setStatus) = React.useState(_ => None)

  // 1. Store the latest onMessage in a ref so we don't need it in the useEffect deps
  let onMessageRef = React.useRef(onMessage)

  // Update the ref whenever the parent passes a new callback
  React.useEffect(() => {
    onMessageRef.current = onMessage
    None
  }, [onMessage])

  // 2. Ref for the channel instance
  let channelRef = React.useRef(Nullable.null)

  React.useEffect(() => {
    // Optional: You could check if client.auth.session() exists here before connecting

    let channel = client->Supabase.Client.channel(
      channelName,
      ~options={
        config: {
          broadcast: {self: false, ack: false},
          private_: true,
        },
      },
    )

    channelRef.current = Nullable.make(channel)

    // 3. Subscription Setup
    // We access onMessageRef.current inside the closure
    let _ = channel->Supabase.Realtime.onBroadcast({"event": event}, res => {
      onMessageRef.current(res.payload)
    })

    channel
    ->Supabase.Realtime.subscribeWithCallback((newStatus, _err) => {
      // In Strict Mode, this might fire for the first 'mount' even after unmount
      // Checking if channelRef is still set prevents setting state on unmounted components
      switch channelRef.current->Nullable.toOption {
      | Some(_) => setStatus(_ => Some(newStatus))
      | None => ()
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
        let _ = client->Supabase.Client.removeChannel(channel)
      },
    )
  }, (client, channelName, event)) // onMessage is deliberately EXCLUDED

  let broadcast = payload => {
    switch channelRef.current->Nullable.toOption {
    | Some(chan) => chan->Supabase.Realtime.send({type_: "broadcast", event, payload})
    | None => Promise.resolve(#error)
    }
  }

  (status, broadcast)
}

// type message = {text: string}

// @react.component
// let make = (~client) => {
//   let (status, send) = useBroadcast(
//     client,
//     ~channelName="chat_room",
//     ~event="message",
//     ~onMessage=m => Js.log2("Received:", m.text)
//   )

//   let handleSendMessage = _ => {
//     // Fire the broadcast and handle the result
//     send({text: "Hello ReScript!"})
//     ->Js.Promise.then_(res => {
//         if res == #error { Js.Console.error("Failed to send") }
//         Js.Promise.resolve()
//       }, _)
//     ->ignore
//   }

//   <div>
//     // Connection status indicator
//     <div className="status-dot">
//       {switch status {
//       | Some(#SUBSCRIBED) => React.string("🟢 Connected")
//       | Some(#CHANNEL_ERROR) => React.string("🔴 Error")
//       | _ => React.string("🟡 Connecting...")
//       }}
//     </div>

//     <button onClick={handleSendMessage}>
//       {React.string("Send Broadcast")}
//     </button>
//   </div>
// }

// type chatMessage = {
//   user: string,
//   text: string,
// }

// @react.component
// let make = (~client) => {
//   let status = useBroadcast(client, ~channelName="room_1", ~event="ping", ~onMessage=_ => {
//     Js.log("Ping received!")
//   })

//   <div>
//     {switch status {
//     | Some(#SUBSCRIBED) => <span style={Style.make(~color="green", ())}> {React.string("Online")} </span>
//     | Some(#CHANNEL_ERROR) => <span style={Style.make(~color="red", ())}> {React.string("Connection Error")} </span>
//     | Some(#TIMED_OUT) => React.string("Timeout...")
//     | _ => React.string("Connecting...")
//     }}
//   </div>
// }

// @react.component
// let make = (~client) => {
//   let (messages, setMessages) = React.useState(_ => [])

//   // Hook handles the sub/unsub automatically
//   useBroadcast(
//     client,
//     ~channelName="room_1",
//     ~event="new_post",
//     ~onMessage=payload => {
//       setMessages(prev => Js.Array2.concat(prev, [payload]))
//     },
//   )

//   <div>
//     {messages
//     ->Js.Array2.map(msg => <p key={msg.text}> {React.string(msg.user ++ ": " ++ msg.text)} </p>)
//     ->React.array}
//   </div>
// }

// Memory Safety: By calling removeChannel in the cleanup function, you prevent "ghost" listeners that continue to run after a user navigates away.

// Dependency Array: The hook will automatically tear down the old connection and start a new one if the channelName or event name changes.

// Type Inference: Because onMessage is passed as a function, ReScript will infer the payload type based on how you use it inside the callback.

// UI Feedback: You can now show different states in your component.

// Error Handling: If the status is #CHANNEL_ERROR, you can trigger a toast or a retry logic.

// Strictness: By using the polymorphic variants (#SUBSCRIBED, etc.), ReScript will force you to handle all cases if you use a switch statement.

// Generic Payload: ReScript's type system will automatically infer the type of the payload based on what you pass into onMessage. If you pass a function that expects a user record, send will also expect a user record.

// Ack configuration: If you need to guarantee the server received the message, remember to change ack: false to ack: true in the hook's channel options.
