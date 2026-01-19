@react.component
let make = (~msg) => {
  <p className="text-stone-100 bg-red-800 text-center font-anon text-sm"> {React.string(msg)} </p>
}
