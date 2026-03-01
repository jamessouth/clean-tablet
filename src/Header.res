@react.component
let make = (~mgt="mt-17", ~username=None, ~head=true, ~color="stone-100") => {
  <header className={`mb-10 ${mgt} `}>
    {switch username {
    | None => React.null
    | Some(u) =>
      <p
        className={`font-flow text-${color} text-3xl tracking-wide absolute top-0 left-1/2 -translate-x-1/2 font-bold `}
      >
        {React.string(u)}
      </p>
    }}
    {switch head {
    | true =>
      <h1 className="text-6xl mx-auto px-6 text-center font-arch decay-mask text-stone-100">
        {React.string("CLEAN TABLET")}
      </h1>
    | false => React.null
    }}
  </header>
}
