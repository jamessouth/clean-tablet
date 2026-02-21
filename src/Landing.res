type formstate = Name | Email | Loading | Error(Supabase.SupaError.t) | Dontshow

let textLinkBase = "w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

@react.component
let make = (~user: Supabase.Auth.user, ~client, ~setHasAuth, ~setNameCookie) => {
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
    ->DB.update({DB.username: formUsername})
    ->DB.abortSignal(signal)
    ->DB.eq("id", id)
    ->DB.single

    Console.log6("upd user name", status, statusText, data, error, count)
    // resp->Auth.getResult

    switch (error, data, count, status, statusText) {
    | (Value(err), _, _, s, st) => setShowForm(_ => SupaError.Db(err, Some(s), Some(st))->Error)
    | (_, _, _, 204, _) =>
      setShowForm(_ => Dontshow)
      setShowToast(_ => Some(`Username changed to ${formUsername}.`))
      setNameCookie(formUsername)
    | (_, _, _, _, _) => setShowForm(_ => SupaError.dbError->Error)
    }

    setFormEmail(_ => "")
    setFormUsername(_ => "")
    setFormSubmitClicked(_ => false)

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
    setFormEmail(_ => "")
    setFormUsername(_ => "")
    setFormSubmitClicked(_ => false)

    switch (error, data) {
    | (Value(err), _) => setShowForm(_ => SupaError.Auth(err)->Error)
    | (_, Value({user: {email, new_email}})) =>
      setShowForm(_ => Dontshow)
      setShowToast(_ => Some(
        `Click the link sent to ${new_email} to complete the change from ${email} to ${new_email}.`,
      ))
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
    setFormEmail(_ => "dd@dd.dd")
    setShowForm(_ => Name)
  }

  let onCxlNameChangeClick = async () => {
    Console.log("on cxl name")
    setFormEmail(_ => "")
    setFormUsername(_ => "")
    setShowForm(_ => Dontshow)
  }

  let onShowEmailFormClick = async () => {
    Console.log("ch email form clckd")
    setFormUsername(_ => "ddd")
    setShowForm(_ => Email)
  }
  let onCxlEmailChangeClick = async () => {
    Console.log("on cxl email")
    setFormEmail(_ => "")
    setFormUsername(_ => "")
    setShowForm(_ => Dontshow)
  }

  <>
    <Menu onSignOutClick onShowNameFormClick onShowEmailFormClick />

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
        css="mb-[15vh]"
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
