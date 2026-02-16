type formstate = Name | Email | Loading | Error(Supabase.SupaError.t) | Dontshow

type namePayload = {username: string}

let textLinkBase = "w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

@react.component
let make = (
  ~user: Supabase.Auth.user,
  ~client,
  ~setHasAuth,
  ~username,
  ~setUsername,
  ~email,
  ~setEmail,
) => {
  let {
    formUsername,
    formEmail,
    formSubmitClicked,
    validationError,
    emailValdnError,
    unameValdnError,
    setFormUsername,
    setFormEmail,
    setFormSubmitClicked,
  } = FormHook.useForm()

  let (showToast, setShowToast) = ToastHook.useToast()

  let {id} = user

  let (showForm, setShowForm) = React.useState(_ => Dontshow)
  let (oldData, setOldData) = React.useState(_ => None)

  let nameRef = React.useRef(None)

  //TODO deal with timeout
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
      setShowForm(_ => Loading)
      setHasAuth(_ => None)
      Web.body(Web.document)
      ->Web.classList
      ->Web.removeClassList3("landingmob", "landingtab", "landingbig")
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

    let (controller, signal) = AbortCtrl.abortCtrl("Name")

    nameRef.current = Some(controller)

    open Supabase
    let {status, statusText, data, error, count} = await client
    ->Client.from("profiles")
    ->DB.update({username: formUsername})
    ->DB.abortSignal(signal)
    ->DB.eq("id", id)
    ->DB.single

    Console.log6("upd user name", status, statusText, data, error, count)
    // resp->Auth.getResult

    switch (error, data, count, status, statusText) {
    | (Value(err), _, _, s, st) => setShowForm(_ => SupaError.Db(err, Some(s), Some(st))->Error)
    | (_, Value({username}), _, _, _) =>
      setShowForm(_ => Dontshow)
      setShowToast(_ => Some(`Username changed to ${username}.`))
      CookieHook.setNameCookie(username)
    | (_, _, _, _, _) => setShowForm(_ => SupaError.dbError->Error)
    }

    switch nameRef.current == Some(controller) {
    | true =>
      nameRef.current = None
      ()
    | false => ()
    }
  }

  //TODO deal with timeout
  let onEmailChangeClick = async () => {
    Console.log("ch email clckd")

    setShowForm(_ => Loading)
    open Supabase
    let {error, data} = await client
    ->Client.auth
    ->Auth.updateUser({email: formEmail})

    Console.log3("upd user email", error, data)

    switch (error, data) {
    | (Value(err), _) => setShowForm(_ => SupaError.Auth(err)->Error)
    | (_, Value({email})) =>
      setShowForm(_ => Dontshow)
      setShowToast(_ => Some(`Email changed to ${email}.`))
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
    // setOldData(_ => username)
    // setUsername(_ => None)
    setShowForm(_ => Name)
  }

  let onCxlNameChangeClick = async () => {
    Console.log("on cxl name")
    // setUsername(_ => oldData)
    // setOldData(_ => "")
    setShowForm(_ => Dontshow)
  }

  let onShowEmailFormClick = async () => {
    Console.log("ch email form clckd")
    // setOldData(_ => email)
    // setEmail(_ => "")
    setShowForm(_ => Email)
  }
  let onCxlEmailChangeClick = async () => {
    Console.log("on cxl email")
    // setEmail(_ => oldData)
    // setOldData(_ => "")
    setShowForm(_ => Dontshow)
  }

  <>
    <Menu onSignOutClick onShowNameFormClick onShowEmailFormClick />

    <Header mgt="mt-17" />
    <nav className="flex flex-col items-center h-[30vh] justify-around mb-8">
      <Link route=Lobby className={textLinkBase ++ "text-4xl"}> {React.string("LOBBY")} </Link>
      <Link route=Leaderboard className={textLinkBase ++ "text-3xl"}>
        {React.string("LEADERBOARD")}
      </Link>
    </nav>

    {switch showToast {
    | None => React.null
    | Loading => <Loading />
    | Some(msg) => <Toast msg setShowToast />
    }}

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
        on_Cxl_Click={switch showForm {
        | Name => onCxlNameChangeClick
        | Email => onCxlEmailChangeClick
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
        setFormSubmitClicked
      >
        {switch showForm {
        | Name =>
          <Input
            value=formUsername
            propName="username"
            inputMode="username"
            setFunc=setFormUsername
            formSubmitClicked
            valdnError=unameValdnError
          />
        | Email =>
          <Input
            value=formEmail
            propName="email"
            inputMode="email"
            setFunc=setFormEmail
            formSubmitClicked
            valdnError=emailValdnError
          />
        | _ => React.null
        }}
      </Form>

    | Error(err) => <SupaErr err />
    | Loading => <Loading />
    | Dontshow => React.null
    }}
  </>
}
