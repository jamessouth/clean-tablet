type t =
  | Username
  | Email
  | Answer

let fromTypeToString = e =>
  switch e {
  | Username => "USERNAME"
  | Email => "EMAIL"
  | Answer => "ANSWER"
  }

let checkLength = (min, max, str) =>
  switch String.length(str) < min || String.length(str) > max {
  | false => ""
  | true => `${Int.toString(min)}-${Int.toString(max)} length; `
  }
let checkInclusion = (re, msg, str) =>
  switch String.match(str, re) {
  | None => msg
  | Some(_) => ""
  }
let checkExclusion = (re, msg, str) =>
  switch String.match(str, re) {
  | None => ""
  | Some(_) => msg
  }

let getFuncs = input =>
  switch input {
  | Username => [
      s => checkLength(3, 10, s), //^\w{3,10}$
      s =>
        checkExclusion(
          /\W/,
          "letters, numbers, and underscores only; no whitespace or symbols; ",
          s,
        ),
    ]
  | Email => [
      s => checkLength(5, 99, s), //^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
      s =>
        checkInclusion(
          /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
          "enter a valid email address.",
          s,
        ),
    ]
  | Answer => [
      s => checkLength(2, 12, s),
      s => checkInclusion(/[a-z ]/i, "letters and spaces only; ", s),
      s => checkExclusion(/\d/, "no numbers; ", s),
      s => checkExclusion(/[!-/:-@\[-`{-~]/, "no symbols; ", s),
      s => checkExclusion(/^\s|\s$/, "must begin and end with letters; ", s), //^[a-zA-Z][a-zA-Z ]{0,10}[a-zA-Z]$
    ]
  }

// let useMultiError = (fields, setErrorFunc) => {
//   let errs = fields->Array.map(fld => {
//     let (val, prop) = fld
//     let error = getFuncs(prop)->Array.reduce("", (acc, f) => acc ++ f(val))
//     switch error == "" {
//     | true => ""
//     | false => fromTypeToString(prop) ++ ": " ++ error
//     }
//   })
//   let total = errs->Array.join("")
//   let final = switch total == "" {
//   | true => None
//   | false => Some(total)
//   }
//   setErrorFunc(_ => final)
// }

let useError = (value, propName, setErrorFunc) => {
  Console.log("Errorhook2")

  let error = getFuncs(propName)->Array.reduce("", (acc, f) => acc ++ f(value))
  let final = switch error == "" {
  | true => None
  | false => Some(fromTypeToString(propName) ++ ": " ++ error)
  }
  setErrorFunc(_ => final)
}
