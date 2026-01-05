open Route
@react.component
let make = (~route, ~className, ~content="") => {
  let onClick = e => {
    ReactEvent.Mouse.preventDefault(e)
    push(route)
  }

  <a onClick className href={typeToUrlString(route)}> {React.string(content)} </a>
}
