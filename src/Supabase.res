module Auth = {
  // ---------------------------------------------------------
  // Types
  // ---------------------------------------------------------

  type user = {
    id: string,
    aud: string,
    role: string,
    email: option<string>,
    created_at: string,
    // Add other user fields as needed (app_metadata, user_metadata, etc.)
  }

  type tokenType = [
    | #bearer
  ]

  type session = {
    access_token: string,
    refresh_token: string,
    expires_in: int,
    token_type: tokenType,
    user: user,
  }

  type error = {
    message: string,
    name: string,
    code: Nullable.t<string>,
    status: Nullable.t<int>,
  }

  type authResp = {
    user: Null.t<user>,
    session: Null.t<session>,
  }

  type authOtpResp = {
    user: Null.t<string>,
    session: Null.t<string>,
    messageId: Null.t<option<string>>,
  }

  type response<'data> = {
    data: Nullable.t<'data>,
    error: Nullable.t<error>,
  }

  type verifyOtpType = [
    | #email
    | #signup
    | #other
  ]

  type verifyOtpParams = {
    @as("type") type_: verifyOtpType,
    token_hash: string,
  }

  // ---------------------------------------------------------
  // Sign In Types
  // ---------------------------------------------------------

  type signInWithOtpOptions = {
    emailRedirectTo?: string, // Vital for Magic Links
    shouldCreateUser?: bool,
    data?: JSON.t, // For passing metadata to the user on creation
    captchaToken?: string,
  }

  type signInWithOtpCredentials = {
    email: string,
    options?: signInWithOtpOptions,
  }

  type loginstate =
    | Loading
    | Error(error)

  // ---------------------------------------------------------
  // Event Types
  // ---------------------------------------------------------

  // Poly-variants for Auth Events (safer than raw strings)
  type event = [
    | #SIGNED_IN
    | #SIGNED_OUT
    | #TOKEN_REFRESHED
    | #USER_UPDATED
    | #USER_DELETED
    | #PASSWORD_RECOVERY
    | #INITIAL_SESSION
  ] // Special event Supabase fires on load

  // The subscription object returned by onAuthStateChange
  type subscription = {
    id: string,
    callback: unit,
    unsubscribe: unit => unit,
  }

  type authStateChangeResponse = {subscription: subscription}

  // ---------------------------------------------------------
  // The Auth Client Interface
  // ---------------------------------------------------------
  type t

  // 1. Get Session
  // ----------------------------
  @send
  external getSession: t => Promise.t<response<option<session>>> = "getSession"

  // 2. Get User (fetches fresh data from DB, unlike getSession which is local)
  // ----------------------------
  @send
  external getUser: t => Promise.t<response<option<user>>> = "getUser"

  // 3. Sign In (Magic Link)
  // ----------------------------
  // Returns session: null because the session isn't ready until they click the link
  @send
  external signInWithOtp: (t, signInWithOtpCredentials) => Promise.t<response<authOtpResp>> =
    "signInWithOtp"

  // 4. Sign Out
  // ----------------------------
  @send
  external signOut: t => Promise.t<option<error>> = "signOut"

  // 5. Auth State Listener
  // ----------------------------
  // Note: The callback receives the event (mapped to poly-variant) and the session (nullable)
  @send
  external onAuthStateChange: (t, (event, option<session>) => unit) => authStateChangeResponse =
    "onAuthStateChange"

  @send
  external verifyOtp: (t, verifyOtpParams) => Promise.t<response<authResp>> = "verifyOtp"

  let getResult = (rspn: response<'data>): result<'data, error> => {
    open Nullable
    switch rspn.error->toOption {
    | Some(er) => Error(er)
    | None =>
      switch rspn.data->toOption {
      | Some(d) => Ok(d)
      | None =>
        Error({
          name: "ResultError",
          status: make(0),
          code: make("invalid_state"),
          message: "both data and error are null",
        })
      }
    }
  }
}

module Realtime = {
  // ---------------------------------------------------------
  // Types
  // ---------------------------------------------------------

  type channel

  type subscribeStatus = [
    | #SUBSCRIBED
    | #TIMED_OUT
    | #CLOSED
    | #CHANNEL_ERROR
  ]

  type sendStatus = [
    | #ok
    | #timed_out
    | #error
  ]

  // The shape of the incoming broadcast packet
  type broadcastResponse<'payload> = {
    event: string,
    payload: 'payload,
  }

  // Configuration for the broadcast behavior
  type broadcastConfig = {
    self?: bool, // Receive your own messages?
    ack?: bool, // Wait for server acknowledgment?
  }

  type channelConfig = {broadcast?: broadcastConfig, @as("private") private_?: bool}
  type channelOptions = {config?: channelConfig}
  // ---------------------------------------------------------
  // Channel Methods
  // ---------------------------------------------------------

  // 1. Subscribe
  // ----------------------------
  @send external subscribe: channel => channel = "subscribe"

  @send external subscribeWithTimeout: (channel, ~timeout: int) => channel = "subscribe"

  @send
  external subscribeWithCallback: (
    channel,
    (subscribeStatus, Nullable.t<JsExn.t>) => unit,
  ) => channel = "subscribe"

  // 2. Unsubscribe
  // ----------------------------
  @send external unsubscribe: channel => Promise.t<sendStatus> = "unsubscribe"

  @send
  external unsubscribeWithTimeout: (channel, ~timeout: int) => Promise.t<sendStatus> = "unsubscribe"

  // 4. Sending Messages (Broadcast)
  // ----------------------------

  // WebSocket Send (Generic)
  // 2. Send a broadcast message
  // If 'ack' is false in channel config, this resolves to 'ok' immediately

  type sendArgs<'a> = {
    @as("type") type_: string, // "broadcast"
    event: string,
    payload: 'a,
  }

  @send external send: (channel, sendArgs<'a>) => Promise.t<sendStatus> = "send"

  // Helper for sending Broadcasts specifically
  let sendBroadcast = (channel, ~event, ~payload) => {
    send(channel, {type_: "broadcast", event, payload})
  }

  // 5. Event Listeners ("on")
  // ----------------------------

  // A. Broadcast Listeners
  // We explicitly bind "broadcast" as the first argument
  @send
  external onBroadcast: (
    channel,
    @as("broadcast") _,
    {"event": string},
    broadcastResponse<'payload> => unit,
  ) => channel = "on"
}

// Channel Name: Use a unique string (e.g., "room_1") for the topic.

// Payload Types: Since ReScript is strictly typed, ensure the 'a in broadcastResponse<'a> matches the type you sent.

// Client-Side Filtering: Use the event key to distinguish between different types of messages (e.g., "CHAT_MSG" vs "USER_TYPING") within the same channel.

module Client = {
  // We use a phantom type 'db to allow you to pass your Database definition later
  // if you want to implement strict typing for tables.
  type t<'db>

  // Placeholder types for sub-clients (Auth, Storage, etc)
  // You can expand these bindings as needed.
  type auth = Auth.t
  type storage
  type realtime
  type functions

  // Accessors for the sub-clients
  @get external auth: t<'db> => auth = "auth"
  @get external storage: t<'db> => storage = "storage"
  @get external realtime: t<'db> => realtime = "realtime"
  @get external functions: t<'db> => functions = "functions"

  // 1. Define the channel method on the client
  @send
  external channel: (t<'db>, string, ~options: Realtime.channelOptions=?) => Realtime.channel =
    "channel"

  @get external getChannels: t<'db> => array<Realtime.channel> = "channels"

  /**
   * Unsubscribes and removes a specific channel from the Realtime client.
   * Returns a promise that resolves to the status of the removal.
   */
  @send
  external removeChannel: (t<'db>, Realtime.channel) => Promise.t<Realtime.sendStatus> =
    "removeChannel"

  /**
   * Unsubscribes and removes ALL channels from the Realtime client.
   */
  @send
  external removeAllChannels: t<'db> => Promise.t<array<Realtime.sendStatus>> = "removeAllChannels"
}

module Options = {
  type flowType = | @as("implicit") Implicit | @as("pkce") PKCE
  type auth = {
    autoRefreshToken?: bool,
    storageKey?: string,
    persistSession?: bool,
    detectSessionInUrl?: bool, // Note: TS allows a function here too, binding to bool for simplicity
    flowType?: flowType,
  }

  type global = {headers?: Dict.t<string>}

  type t = {
    auth?: auth,
    realtime?: JSON.t, // Binding as generic JSON for now
    storage?: JSON.t, // Binding as generic JSON for now
    global?: global,
  }
}

// Main createClient binding
@module("@supabase/supabase-js")
external createClient: (string, string, ~options: Options.t=?) => Client.t<'db> = "createClient"
