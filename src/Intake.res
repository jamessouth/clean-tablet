@react.component
let make = () => {
  <Form
    ht={switch hasNameCookie {
    | true => "h-46"
    | false => "h-54"
    }}
    on_Click
    leg="Sign in"
    validationError
    setSubmitClicked
  >
    {switch hasNameCookie {
    | true => React.null
    | false =>
      <Input
        value=username
        propName="username"
        inputMode="username"
        setFunc=setUsername
        submitClicked
        valdnError=unameValdnError
      />
    }}

    <Input
      value=email
      propName="email"
      inputMode="email"
      setFunc=setEmail
      submitClicked
      valdnError=emailValdnError
    />
  </Form>
}
