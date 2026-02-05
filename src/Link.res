open Route
@react.component
let make = (~route, ~textsize, ~content="") => {
  let onClick = e => {
    ReactEvent.Mouse.preventDefault(e)
    push(route)
  }

  <a
    onClick
    className={`w-5/6 border border-stone-100 bg-stone-800/40 text-center text-stone-100 decay-mask p-2 max-w-80 font-fred ${textsize}`}
    href={typeToUrlString(route)}
  >
    {React.string(content)}
  </a>
}
