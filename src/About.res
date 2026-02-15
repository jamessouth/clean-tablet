@react.component
let make = () => {
  <div className="flex flex-col max-h-96 justify-between items-center mt-12 h-[80vh]">
    <h2 className="text-5xl font-arch decay-mask text-stone-100"> {React.string("ABOUT")} </h2>

    <p className="text-2xl text-center px-4 font-arch text-stone-100">
      {React.string("All artwork by ")}
      <a href="https://en.wikipedia.org/wiki/Theodor_Kittelsen" rel="noopener noreferrer">
        {React.string("Theodor Kittelsen")}
      </a>
      {React.string(". All images sourced from ")}
      <a
        href="https://commons.wikimedia.org/wiki/Category:Theodor_Kittelsen"
        rel="noopener noreferrer"
      >
        {React.string("Wikimedia Commons")}
      </a>
      {React.string(
        " and believed to be in the public domain since Kittelsen died over 100 years ago.",
      )}
    </p>

    <a
      href="https://github.com/jamessouth/clean-tablet"
      className="w-8 h-8"
      rel="noopener noreferrer"
    >
      <svg
        className="w-8 h-8 fill-stone-100 absolute"
        viewBox="0 0 32 32"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M16 2a14 14 0 0 0-4.43 27.28c.7.13 1-.3 1-.67v-2.38c-3.89.84-4.71-1.88-4.71-1.88a3.71 3.71 0 0 0-1.62-2.05c-1.27-.86.1-.85.1-.85a2.94 2.94 0 0 1 2.14 1.45a3 3 0 0 0 4.08 1.16a2.93 2.93 0 0 1 .88-1.87c-3.1-.36-6.37-1.56-6.37-6.92a5.4 5.4 0 0 1 1.44-3.76a5 5 0 0 1 .14-3.7s1.17-.38 3.85 1.43a13.3 13.3 0 0 1 7 0c2.67-1.81 3.84-1.43 3.84-1.43a5 5 0 0 1 .14 3.7a5.4 5.4 0 0 1 1.44 3.76c0 5.38-3.27 6.56-6.39 6.91a3.33 3.33 0 0 1 .95 2.59v3.84c0 .46.25.81 1 .67A14 14 0 0 0 16 2Z"
        />
      </svg>
    </a>

    <p className="text-lg font-arch text-stone-100"> {React.string("© 2026 James South")} </p>
  </div>
}
