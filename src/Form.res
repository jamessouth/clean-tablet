@react.component
let make = (
  ~ht="h-46",
  ~on_Click,
  ~leg,
  ~validationError,
  ~setSubmitClicked,
  ~children=React.null,
) => {
  <form className="w-4/5 m-auto relative mb-[5vh]">
    <fieldset className={`flex flex-col items-center justify-around ${ht}`}>
      {switch String.length(leg) > 0 {
      | true =>
        <legend className="text-stone-100 m-auto mb-6 text-4xl font-fred">
          {React.string(leg)}
        </legend>
      | false => React.null
      }}

      {children}
    </fieldset>
    // {switch (submitClicked, leg == "Sign in", validationError) {
    // | (false, _, _)
    // | (true, false, _)
    // | (true, true, Some(_)) => React.null
    // | (true, true, None) =>
    //   <div className="absolute left-1/2 transform -translate-x-2/4 bottom-10">
    //     <Loading label="..." />
    //   </div>
    // }}
    <Button
      onClick={_ => {
        setSubmitClicked(_ => true)
        switch validationError {
        | true => ()
        | false => on_Click()->ignore
        }
      }}
    >
      {React.string("submit")}
    </Button>
  </form>
}
