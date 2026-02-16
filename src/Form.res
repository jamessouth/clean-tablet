@react.component
let make = (
  ~ht="h-46",
  ~on_Click,
  ~on_Cxl_Click=?,
  ~leg,
  ~validationError,
  ~setFormSubmitClicked,
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
    <div
      className={switch on_Cxl_Click {
      | Some(_) => "flex"
      | None => ""
      }}
    >
      {switch on_Cxl_Click {
      | Some(f) => <Button onClick={_ => f()->ignore}> {React.string("cancel")} </Button>
      | None => React.null
      }}
      <Button
        onClick={_ => {
          setFormSubmitClicked(_ => true)
          switch validationError {
          | true => ()
          | false => on_Click()->ignore
          }
        }}
      >
        {React.string("submit")}
      </Button>
    </div>
  </form>
}
