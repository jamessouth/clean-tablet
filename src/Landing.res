type formstate = Name | Email | Loading | Error(Supabase.SupaError.t) | Dontshow

type namePayload = {uname: string}

@react.component
let make = (~user: Supabase.Auth.user, ~client, ~setHasAuth, ~setUser) => {
  let {
    username,
    setUsername,
    email,
    setEmail,
    submitClicked,
    setSubmitClicked,
    validationError,
    emailValdnError,
    unameValdnError,
  } = FormHook.useForm()

  let {id} = user
  //   let {username} = user.user_metadata

  let (showForm, setShowForm) = React.useState(_ => Dontshow)

  let nameRef = React.useRef(None)

  let onSignOutClick = async () => {
    Console.log("sinout clckd")

    open Supabase
    let {error} = await client
    ->Client.auth
    ->Auth.signOut

    Console.log2("ee", error)

    switch error {
    | Value(err) =>
      Console.log2("sinout err", err)
      setShowForm(_ => SupaError.Auth(err)->Error)

    | _ =>
      Console.log("logged out")
      setShowForm(_ => Dontshow)
      setHasAuth(_ => false)
      setUser(_ => None)
      Web.body(Web.document)
      ->Web.classList
      ->Web.removeClassList3("landingmob", "landingtab", "landingbig")
    // Route.push(SignIn)
    //redirect
    }
  }

  let onNameChangeClick = async () => {
    Console.log("ch name clckd")
    setShowForm(_ => Loading)

    switch nameRef.current {
    | Some(ctrlr) =>
      ctrlr->Fetch.AbortController.abort(~reason="timeout or user abort")
      Console.log("name change cxld")
    | None => ()
    }

    open Fetch

    let controller = AbortController.make()

    let timeoutSignal = AbortSignal.timeout(10_000)
    let manualSignal = AbortController.signal(controller)

    let timeoutHandler = _ => Console.log("name Request timed out after 10s")
    let manualHandler = _ => Console.log("name Request aborted manually")

    let signal = AbortSignal.any([timeoutSignal, manualSignal])

    AbortSignal.addEventListener(
      timeoutSignal,
      #abort(timeoutHandler),
      ~options={once: true, signal},
    )
    AbortSignal.addEventListener(manualSignal, #abort(manualHandler), ~options={once: true, signal})

    nameRef.current = Some(controller)

    open Supabase
    let {status, statusText, data, error, count} = await client
    ->Client.from("profiles")
    ->DB.update({uname: username})
    ->DB.abortSignal(signal)
    ->DB.eq("id", id)
    ->DB.single

    Console.log6("upd user name", status, statusText, data, error, count)
    // resp->Auth.getResult

    switch (error, data, count, status, statusText) {
    | (Value(err), _, _, s, st) => setShowForm(_ => SupaError.Db(err, Some(s), Some(st))->Error)
    | (_, Value(_data), _, _, _) => setShowForm(_ => Dontshow)
    // show toast
    | (_, _, _, _, _) => setShowForm(_ => SupaError.dbError->Error)
    }

    switch nameRef.current == Some(controller) {
    | true =>
      nameRef.current = None
      ()
    | false => ()
    }
  }

  let onEmailChangeClick = async () => {
    Console.log("ch email clckd")

    setShowForm(_ => Loading)
    open Supabase
    let {error, data} = await client
    ->Client.auth
    ->Auth.updateUser({email: email})

    Console.log3("upd user email", error, data)

    switch (error, data) {
    | (Value(err), _) => setShowForm(_ => SupaError.Auth(err)->Error)
    | (_, Value(_user)) => setShowForm(_ => Dontshow)
    // show toast
    | (_, _) =>
      setShowForm(_ =>
        SupaError.Auth({
          name: "UpdateUserError",
          status: Nullable.make(0),
          code: Nullable.make("invalid_state"),
          message: "both data and error are null",
        })->Error
      )
    }
  }

  let onShowNameFormClick = async () => {
    Console.log("ch name form clckd")
    setShowForm(_ => Name)
  }
  let onShowEmailFormClick = async () => {
    Console.log("ch email form clckd")
    setShowForm(_ => Email)
  }

  <>
    <Menu onSignOutClick onShowNameFormClick onShowEmailFormClick />

    <Header mgt="mt-17" />
    <nav className="flex flex-col items-center h-[30vh] justify-around">
      <Link route=Lobby textsize="text-4xl" content="LOBBY" />
      <Link route=Leaderboard textsize="text-3xl" content="LEADERBOARD" />
    </nav>

    {switch showForm {
    | Name | Email =>
      <Form
        on_Click={switch showForm {
        | Name => onNameChangeClick
        | Email => onEmailChangeClick
        | _ =>
          async () => {
            ()
          }
        }}
        leg={switch showForm {
        | Name => "Update name"
        | Email => "Update email"
        | _ => ""
        }}
        validationError
        setSubmitClicked
      >
        {switch showForm {
        | Name =>
          <Input
            value=username
            propName="username"
            inputMode="username"
            setFunc=setUsername
            submitClicked
            valdnError=unameValdnError
          />
        | Email =>
          <Input
            value=email
            propName="email"
            inputMode="email"
            setFunc=setEmail
            submitClicked
            valdnError=emailValdnError
          />
        | _ => React.null
        }}
      </Form>

    | Error(err) => <SupaErrToast err />
    | Loading => <Loading />
    | Dontshow => React.null
    }}
  </>
}
