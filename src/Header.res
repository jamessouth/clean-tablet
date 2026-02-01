@react.component
let make = (~mgt="mt-17", ~username=?) => {
  <>
    {switch username {
    | Some(un) =>
      <p
        className="font-flow text-stone-100 text-3xl tracking-wide absolute top-0 left-1/2 -translate-x-1/2 font-bold "
      >
        {React.string(un)}
      </p>
    | None => React.null
    }}

    <header className={`mb-10 ${mgt} newgmimg:mb-12`}>
      <h1 className="text-6xl mx-auto px-6 text-center font-arch decay-mask text-stone-100">
        {React.string("CLEAN TABLET")}
      </h1>
    </header>
  </>
}
