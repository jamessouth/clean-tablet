let landingLinkStyles = "w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred "

type formstate = Name | Email | Loading | Error(Supabase.Error.t) | None

type namePayload = {uname: string}

@react.component
let make = (
  ~user: Supabase.Auth.user,
  ~client,
  ~setHasAuth,
  ~setUser: (option<Supabase.Auth.user> => option<Supabase.Auth.user>) => unit,
) => {
  let {
    username,
    setUsername,
    email,
    setEmail,
    submitClicked,
    setSubmitClicked,
    validationError,
    // setValidationError,
    emailValdnError,
    // setEmailValdnError,
    unameValdnError,
    // setUnameValdnError,
  } = FormHook.useForm()

  let {id} = user
  //   let {username} = user.user_metadata

  let (showForm, setShowForm) = React.useState(_ => None)

  let onSignOutClick = async () => {
    Console.log("sinout clckd")

    setHasAuth(_ => false)
    setUser(_ => None)
    // Route.push(SignIn)

    open Supabase
    let error = await client
    ->Client.auth
    ->Auth.signOut

    switch Nullable.toOption(error) {
    | Some(err) =>
      Console.log2("err", err)
      setShowForm(_ => Supabase.Error.Auth(err)->Error)

    | None =>
      Console.log("Check your email for the login link!")
      setShowForm(_ => None)
    //redirect
    }
  }

  let onNameChangeClick = async () => {
    Console.log("ch name clckd")
    setShowForm(_ => Loading)
    open Supabase
    let resp = await client
    ->Client.from("profiles")
    ->DB.update({uname: username})
    ->DB.eq("id", id)
    ->DB.single

    Console.log2("upd user name", resp)
    // resp->Auth.getResult

    switch resp->DB.getResult {
    | Ok(_) => setShowForm(_ => None)
    // show toast

    | Error(err) => setShowForm(_ => Supabase.Error.Db(err)->Error)
    }
  }

  let onEmailChangeClick = async () => {
    Console.log("ch email clckd")

    setShowForm(_ => Loading)
    open Supabase
    let resp = await client
    ->Client.auth
    ->Auth.updateUser({email: email})

    Console.log2("upd user email", resp)
    // resp->Auth.getResult

    switch resp->Auth.getResult {
    | Ok(_) => setShowForm(_ => None)
    // show toast

    | Error(err) => setShowForm(_ => Supabase.Error.Auth(err)->Error)
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
        ht="h-46"
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
    | None => React.null
    }}
  </>
}
