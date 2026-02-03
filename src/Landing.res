let landingLinkStyles = "w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

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
    // Route.push(SignIn)
    //redirect
    }
  }

  let onNameChangeClick = async () => {
    Console.log("ch name clckd")
    setShowForm(_ => Loading)
    open Supabase
    let {status, statusText, data, error, count} = await client
    ->Client.from("profiles")
    ->DB.update({uname: username})
    ->DB.eq("id", id)
    ->DB.single

    Console.log6("upd user name", status, statusText, data, error, count)
    // resp->Auth.getResult

    switch (error, data, count, status, statusText) {
    | (Value(err), _, _, _, _) => setShowForm(_ => SupaError.Db(err)->Error)
    | (_, Value(_data), _, _, _) => setShowForm(_ => Dontshow)
    // show toast
    | (_, _, _, _, _) =>
      setShowForm(_ =>
        SupaError.Db({
          message: "invalid state",
          name: "UpdateError",
          details: "both data and error are null",
          hint: "bad response",
          code: "520",
        })->Error
      )
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
      <Link route=Lobby className={landingLinkStyles ++ "text-4xl"} content="LOBBY" />
      <Link route=Leaderboard className={landingLinkStyles ++ "text-3xl"} content="LEADERBOARD" />
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
