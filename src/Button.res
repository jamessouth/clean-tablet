@react.component
let make = (
  ~onClick,
  ~disabled=false,
  ~className="text-stone-800 hover:bg-stone-400 block max-w-xs lg:max-w-sm font-flow text-2xl mx-auto cursor-pointer w-3/5 h-7 rounded-sm ",
  ~css="bg-stone-100 mt-8",
  ~children,
) => {
  <button type_="button" className={className ++ css} onClick disabled> {children} </button>
}
