@react.component
let make = (~msg, ~setShowToast) => {
  <div
    className="absolute z-1 left-1/2 -translate-x-1/2 text-stone-100 bg-green-600 font-anon w-3/4 min-h-10 max-w-sm"
  >
    <Button
      onClick={_ => setShowToast(_ => None)}
      className="text-3xl absolute w-9 h-9 top-0 right-0 cursor-pointer"
    >
      {React.string("X")}
    </Button>
    <p className={" w-4/5 mx-auto text-center"}> {React.string(msg)} </p>
  </div>
}
