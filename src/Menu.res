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
  <>
    <button
      onClick={handleMenuClick}
      className="flex flex-col absolute top-1 left-1 justify-evenly h-6 w-6 self-start cursor-pointer "
    >
      <Line
        menuIsOpen
        trans="transform"
        openTrue="origin-left rotate-[24deg] scale-x-133"
        openFalse="-translate-y-0.5"
      />
      <Line menuIsOpen trans="opacity" openTrue="opacity-0" openFalse="opacity-100" />
      <Line
        menuIsOpen
        trans="transform"
        openTrue="origin-left -rotate-[24deg] scale-x-133"
        openFalse="translate-y-0.5"
      />
    </button>
    <div
      className={"flex flex-col top-12 left-1 absolute bg-stone-100/10 font-anon justify-around items-center z-1 " ++
      switch menuIsOpen {
      | true => "block"
      | false => "hidden"
      }}
    >
      <button className="cursor-pointer" onClick={_ => Console.log("a")}>
        <img className="block" src="/src/assets/signout.png" />
      </button>
    </div>
  </>
}
