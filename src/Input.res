@react.component
let make = (
  ~value,
  ~propName,
  ~autoComplete=propName,
  ~inputMode="text",
  ~onKeyPress=_e => (),
  ~setFunc,
  ~formSubmitClicked,
  ~valdnError,
) => {
  let onChange = e => setFunc(_ => ReactEvent.Form.target(e)["value"])

  <div className="max-w-xs lg:max-w-sm w-full">
    <label className="text-2xl font-flow text-stone-100" htmlFor=autoComplete>
      {React.string(propName)}
    </label>
    <input
      autoComplete
      className="h-6 w-full text-xl outline-none font-anon bg-transparent border-b-1 text-stone-100 border-stone-100 indent-2px"
      id=autoComplete
      inputMode
      name=propName
      onChange
      onKeyPress
      spellCheck=false
      type_={switch propName == "username" || propName == "answer" {
      | true => "text"
      | false => propName
      }}
      value
    />
    {switch (formSubmitClicked, valdnError) {
    | (false, _) | (true, None) => React.null
    | (true, Some(error)) => <Message msg=error />
    }}
  </div>
}
