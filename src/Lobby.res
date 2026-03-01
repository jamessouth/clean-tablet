%%raw("import './css/lobby.css'")

@react.component
let make = (~username, ~client) => {
  let (lobbystate, setLobbyState) = React.useState(_ => Supabase.Global.Loading)

  React.useEffect(() => {
    Console.log("in lobby eff")

    let (controller, signal) = AbortCtrl.abortCtrl("Lobby")

    let loadGames = async () => {
      Console.log("loadgames func")
      open Supabase
      let {status, statusText, data, error, count} = await client
      ->Client.from("games")
      ->DB.select("id, game_status")
      ->DB.abortSignal(signal)
      ->DB.eqExec("game_status", Game.NotStarted)

      Console.log6("loadgames", status, statusText, data, error, count)
      // resp->Auth.getResult

      switch (error, data, count, status, statusText) {
      | (Value(err), _, _, s, st) =>
        switch err.message->String.includes("FetchError: undefined") {
        | true => Console.log("eating abort err")
        | false => setLobbyState(_ => SupaError.Db(err, Some(s), Some(st))->Error)
        }
      | (_, Value(data), _, _, _) => setLobbyState(_ => Success(data))
      | (_, _, _, _, _) => setLobbyState(_ => SupaError.dbError->Error)
      }
    }

    loadGames()->ignore

    Some(() => controller->Fetch.AbortController.abort(~reason="timeout or user abort"))
  }, [])

  <>
    <h2 className="text-center text-stone-800 text-5xl mt-28 font-fred">
      {React.string("LOBBY")}
    </h2>
    <Button
      css=""
      className="w-15 h-7 border bg-stone-800/5 border-stone-800 absolute top-0 left-0 cursor-pointer"
      onClick={_ => Route.push(Landing)}
    >
      <p className="leading-none text-stone-800 text-2xl"> {React.string("⬅")} </p>
    </Button>
    <div className="my-16 ">
      {switch lobbystate {
      | Loading => <Loading color="stone-800" label="games..." />
      | Error(err) => <SupaErr err />
      | Success(games) =>
        // md:grid grid-cols-2 gap-8) lg:(gap-10 justify-items-center) xl:(grid-cols-3 gap-12 max-w-1688px)

        <ul className="w-11/12 mx-auto">
          {games
          ->Array.map(game => {
            <Game key={Int.toString(game.id)} client game username />
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
