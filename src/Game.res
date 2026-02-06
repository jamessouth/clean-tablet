let btnStyle = " cursor-pointer text-base font-bold text-stone-100 font-anon w-1/2 bottom-0 h-8 absolute bg-stone-700 bg-opacity-70 filter disabled:(cursor-not-allowed contrast-25)"

@react.component
let make = (~game) => {
  let {id} = game

  let bg = "game" ++ Int.toString(Int.mod(id, 10))

  let liStyle = `<md:mb-16 grid grid-cols-2 grid-rows-6 relative text-xl bg-bottom bg-no-repeat h-200px text-center font-bold text-dark-800 font-anon pb-8 ${bg} lg:(max-w-lg w-full)`

  <li>
    <p className="absolute text-stone-100 text-xs left-1/2 transform -translate-x-2/4 -top-3.5">
      {React.string(id)}
    </p>
    <p className="col-span-2" />

    <Button
      onClick={_ => Console.log("game btn")} disabled=disabledJoin className={"left-0" ++ btnStyle}
    >
    </Button>
  </li>
}
