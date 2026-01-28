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
let make = (~onSignOutClick, ~onNameChangeClick, ~onEmailChangeClick) => {
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
      className={"flex flex-col top-12 left-1 absolute bg-stone-600/80 justify-around items-center z-1 h-32 " ++
      switch menuIsOpen {
      | true => "block"
      | false => "hidden"
      }}
    >
      <button className="cursor-pointer" onClick={_ => onSignOutClick()->Promise.ignore}>
        <img className="block" src="/src/assets/signout.png" />
      </button>

      <button className="cursor-pointer" onClick={_ => onNameChangeClick()->Promise.ignore}>
        <img className="block" src="/src/assets/name.png" />
      </button>

      <button className="cursor-pointer" onClick={_ => onEmailChangeClick()->Promise.ignore}>
        <img className="block" src="/src/assets/email.png" />
      </button>
    </div>
  </>
}
