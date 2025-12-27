// let username_max_length = 10
let email_max_length = 99

@react.component
let make = () => {
  let (email, setEmail) = React.Uncurried.useState(_ => "")
  let (validationError, setValidationError) = React.Uncurried.useState(_ => Some(
    "EMAIL: 5-99 length; enter a valid email address.",
  ))

  React.useEffect1(() => {
    ErrorHook.useError(email, Email, setValidationError)
    None
  }, [email])

  //   React.useEffect0(() => {
  //     Js.log("signin use effect")

  //     ImageLoad.import_("./ImageLoad.bs")
  //     ->Promise.then(func => {
  //       Promise.resolve(func["bghand"](.))
  //     })
  //     ->ignore

  //     None
  //   })

  let on_Click = () => {
    switch validationError {
    | None => {
        let cbs = {
          onSuccess: res => {
            setCognitoError(_ => None)
            Js.log2("signin result:", res)
            setToken(_ => Some(res.idToken.jwtToken))
          },
          onFailure: ex => {
            switch Js.Exn.message(ex) {
            | Some(msg) => setCognitoError(_ => Some(msg))
            | None => setCognitoError(_ => Some("unknown signin error"))
            }

            setCognitoUser(_ => Js.Nullable.null)
            Js.log2("problem", ex)
          },
          newPasswordRequired: Js.Nullable.null,
          mfaRequired: Js.Nullable.null,
          customChallenge: Js.Nullable.null,
        }
        let authnData = {
          username: username
          ->Js.String2.slice(~from=0, ~to_=username_max_length)
          ->Js.String2.replaceByRe(/\W/g, ""),
          password: password
          ->Js.String2.slice(~from=0, ~to_=password_max_length)
          ->Js.String2.replaceByRe(/\s/g, ""),
          validationData: Js.Nullable.null,
          authParameters: Js.Nullable.null,
          clientMetadata: Js.Nullable.null,
        }
        let authnDetails = authenticationDetailsConstructor(authnData)

        switch Js.Nullable.isNullable(cognitoUser) {
        | true => {
            let userdata = {
              username: username
              ->Js.String2.slice(~from=0, ~to_=username_max_length)
              ->Js.String2.replaceByRe(/\W/g, ""),
              pool: userpool,
            }
            let user = Js.Nullable.return(userConstructor(userdata))
            user->authenticateUser(authnDetails, cbs)
            setCognitoUser(_ => user)
          }

        | false => cognitoUser->authenticateUser(authnDetails, cbs)
        }
      }

    | Some(_) => ()
    }
  }

  <Form on_Click leg="Sign in" validationError cognitoError>
    <Input value=username propName="username" setFunc=setUsername />
    <Input value=password propName="password" autoComplete="current-password" setFunc=setPassword />
  </Form>
}
