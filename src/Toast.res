@react.component
let make = (~msg, ~setShowToast: (ToastHook.toastState => ToastHook.toastState) => unit) => {
  <div
    className="absolute z-1 left-1/2 -translate-x-1/2 text-stone-100 bg-green-600 font-anon w-3/4 flex justify-around max-w-sm"
  >
    <p className={"px-2 text-center leading-[2]"}> {React.string(msg)} </p>
    <Button onClick={_ => setShowToast(_ => None)} className="text-2xl w-8 h-8 cursor-pointer">
      {React.string("X")}
    </Button>
  </div>
}
