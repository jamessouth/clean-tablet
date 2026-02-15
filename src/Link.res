open Route
@react.component
let make = (~route, ~className, ~children) => {
  let onClick = e => {
    ReactEvent.Mouse.preventDefault(e)
    push(route)
  }

  <a onClick className href={typeToUrlString(route)}> {children} </a>
}
