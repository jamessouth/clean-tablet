@react.component
let make = (~msg, ~css="") => {
  <p className={`text-stone-100 bg-red-800 text-center font-anon text-sm ${css}`}>
    {React.string(msg)}
  </p>
}
