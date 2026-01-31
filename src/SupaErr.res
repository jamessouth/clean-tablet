@react.component
let make = (~err) => {
  let arr = getError(err)
  let len = 5
  arr
  ->Array.mapWithIndex((x, i) => {
    let first = switch i == 0 {
    | true => " pt-2"
    | false => ""
    }
    let last = switch i + 1 == len {
    | true => " pb-2 mb-[5vh]"
    | false => ""
    }
    <p
      key=x
      className={`text-stone-100 bg-red-600 font-anon w-4/5 mx-auto max-w-sm text-center${first}${last}`}
    >
      {React.string(x)}
    </p>
  })
  ->React.array
}
