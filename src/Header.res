@react.component
let make = (~mgt) => {
  <header className={`mb-10 ${mgt} newgmimg:mb-12`}>
    <h1 className="text-6xl mx-auto px-6 text-center font-arch decay-mask text-stone-100">
      {React.string("CLEAN TABLET")}
    </h1>
  </header>
}
