module Line = {
  @react.component
  let make = (~menuIsOpen, ~trans, ~openTrue, ~openFalse) => {
    <span
      className={`bg-stone-100 transition-${trans} duration-300 ease-out h-0.5 w-6 rounded-sm ` ++
      switch menuIsOpen {
      | true => openTrue
      | false => openFalse
      }}
    />
  }
}

@react.component
let make = () => {
  let (menuIsOpen, setMenuIsOpen) = React.useState(_ => false)

  let handleMenuClick = _ => {
    setMenuIsOpen(prev => !prev)
  }

  <div
    className={"flex flex-col h-[14vh] absolute top-1 left-1 font-anon justify-center items-center z-1 " ++
    switch menuIsOpen {
    | true => ""
    | false => ""
    }}
  >
    <button
      onClick={handleMenuClick}
      className="flex flex-col absolute top-0 justify-evenly h-6 w-6 self-start "
    >
      <Line
        menuIsOpen
        trans="transform"
        openTrue="origin-left rotate-[33deg]"
        openFalse="-translate-y-0.5"
      />
      <Line menuIsOpen trans="opacity" openTrue="opacity-0" openFalse="opacity-100" />
      <Line
        menuIsOpen
        trans="transform"
        openTrue="origin-left -rotate-[33deg]"
        openFalse="translate-y-0.5"
      />
    </button>
    {switch menuIsOpen {
    | true =>
      <button onClick={_ => Console.log("a")}>
        <img className="block" src="/src/assets/signout.png" />
      </button>
    | false => React.null
    }}
  </div>
}
