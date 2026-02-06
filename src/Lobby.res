%%raw("import './css/lobby.css'")

@react.component
let make = (~user: Supabase.Auth.user, ~client) => {
  let {username} = user.user_metadata

  let (lobbystate, setLobbyState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    Console.log("in lobby eff")

    open Fetch

    let controller = AbortController.make()

    let timeoutSignal = AbortSignal.timeout(30_000)
    let manualSignal = AbortController.signal(controller)

    let timeoutHandler = _ => Console.log("lobby Request timed out after 30s")
    let manualHandler = _ => Console.log("lobby Request aborted manually")

    let signal = AbortSignal.any([timeoutSignal, manualSignal])

    AbortSignal.addEventListener(
      timeoutSignal,
      #abort(timeoutHandler),
      ~options={once: true, signal},
    )
    AbortSignal.addEventListener(manualSignal, #abort(manualHandler), ~options={once: true, signal})

    let loadGames = async () => {
      Console.log("loadgames func")
      open Supabase
      let {status, statusText, data, error, count} = await client
      ->Client.from("games")
      ->DB.select("id, game_status")
      ->DB.abortSignal(signal)
      ->DB.eq("game_status", Game.NotStarted)
      ->DB.single

      Console.log6("loadgames", status, statusText, data, error, count)
      // resp->Auth.getResult

      switch (error, data, count, status, statusText) {
      | (Value(err), _, _, _, _) => setLobbyState(_ => SupaError.Db(err)->Error)
      | (_, Value(data), _, _, _) => setLobbyState(_ => Success(data))
      // show toast
      | (_, _, _, _, _) => setLobbyState(_ => SupaError.dbError->Error)
      }
    }

    loadGames()

    Some(() => controller.abort())
  }, [])

  <>
    <p
      className="font-flow text-stone-800 text-3xl tracking-wide absolute top-0 left-1/2 -translate-x-1/2 font-bold "
    >
      {React.string(username)}
    </p>
    <h2 className="text-center text-stone-800 text-5xl mt-28 font-fred">
      {React.string("LOBBY")}
    </h2>
    <button
      className="w-15 h-7 border bg-stone-800/5 border-stone-800 absolute top-0 left-0 cursor-pointer"
      onClick={_ => Route.push(Landing)}
    >
      <p className="text-2xl"> {React.string("⬅")} </p>
    </button>
    <div className="flex flex-col items-center">
      {switch lobbystate {
      | Loading => <Loading label="games..." />
      | Error(err) => <SupaErrToast err />
      | Success(games) =>
        <ul
          className="m-12 newgmimg:mt-14 w-11/12 <md:(flex max-w-lg flex-col) md:(grid grid-cols-2 gap-8) lg:(gap-10 justify-items-center) xl:(grid-cols-3 gap-12 max-w-1688px)"
        >
          {games
          ->Array.map(game => {
            <Game key=game.id game />
          })
          ->React.array}
        </ul>
      }}
    </div>
  </>
}

// import React, { useState, useEffect } from 'react';

// const DataFetcher = ({ url }) => {
//   const [data, setData] = useState(null);
//   const [error, setError] = useState(null);
//   const [isLoading, setIsLoading] = useState(true);

//   useEffect(() => {
//     // 1. Create an AbortController instance
//     const controller = new AbortController();
//     const signal = controller.signal;

//     const fetchData = async () => {
//       setIsLoading(true);
//       try {
//         // 2. Pass the signal to fetch
//         const response = await fetch(url, { signal });
//         if (!response.ok) {
//           throw new Error(`HTTP error! status: ${response.status}`);
//         }
//         const result = await response.json();
//         setData(result);
//         setError(null);
//       } catch (err) {
//         // 4. Handle the abort error
//         if (err.name === 'AbortError') {
//           console.log('Fetch request was aborted');
//         } else {
//           setError(err);
//         }
//       } finally {
//         // This is necessary to avoid setting state on an unmounted component
//         if (!signal.aborted) {
//             setIsLoading(false);
//         }
//       }
//     };

//     fetchData();

//     // 3. Implement a cleanup function to abort the request
//     return () => {
//       controller.abort();
//     };
//   }, [url]); // Re-run effect if URL changes

//   if (isLoading) return <p>Loading data...</p>;
//   if (error) return <p>Error: {error.message}</p>;

//   return (
//     <div>
//       <h2>Data Loaded:</h2>
//       <pre>{JSON.stringify(data, null, 2)}</pre>
//     </div>
//   );
// };

// export default DataFetcher;
