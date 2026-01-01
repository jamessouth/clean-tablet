%%raw(`import './css/leader.css'`)

type stat = {
  name: string,
  wins: int,
  points: int,
  games: int,
  winPct: float,
  ppg: float,
}

type field =
  | Name
  | Wins
  | Points
  | Games
  | WinPercentage
  | PointsPerGame

type sortDirection = Up | Down

let sortData = (field, dir, a: stat, b: stat) => {
  let res = switch field {
  | Name => compare(a.name, b.name)
  | Wins => compare(a.wins, b.wins)
  | Points => compare(a.points, b.points)
  | Games => compare(a.games, b.games)
  | WinPercentage => compare(a.winPct, b.winPct)
  | PointsPerGame => compare(a.ppg, b.ppg)
  }

  switch dir {
  | Up => -Int.toFloat(res)
  | Down => Int.toFloat(res)
  }
}

@react.component
let make = (~playerName, ~setLeaderData) => {
  let (nameDir, setNameDir) = React.Uncurried.useState(_ => Down)
  let (winDir, setWinDir) = React.Uncurried.useState(_ => Down)
  let (ptsDir, setPtsDir) = React.Uncurried.useState(_ => Up)
  let (gamesDir, setGamesDir) = React.Uncurried.useState(_ => Up)
  let (winPctDir, setWinPctDir) = React.Uncurried.useState(_ => Up)
  let (ppgDir, setPPGDir) = React.Uncurried.useState(_ => Up)

  let (sortedField, setSortedField) = React.Uncurried.useState(_ => Wins)
  let (arrowClass, setArrowClass) = React.Uncurried.useState(_ => "downArrow")

  let (data, setData) = React.Uncurried.useState(_ => [])

  Console.log("leadersssss")
  //   React.useEffect1(() => {
  //     Console.log("leaders useeff")

  //     switch Array.length(leaderData) == 0 {
  //     | true =>
  //       send(
  //         Lobby.payloadToObj({
  //           act: Query,
  //           cmd: Leaders,
  //         }),
  //       )

  //     | false => setData(_ => leaderData->Array.copy)
  //     }

  //     None
  //   }, [leaderData]) //TODO remove as unneeded

  let onClick = (field, dir, func) => {
    setSortedField(_ => field)
    switch dir {
    | Up => {
        setArrowClass(_ => "downArrow")
        func(_ => Down)
      }

    | Down => {
        setArrowClass(_ => "upArrow")
        func(_ => Up)
      }
    }

    setData(_ => data->Array.toSorted((a, b) => sortData(field, dir, a, b)))
  }

  <div className="leadermobbg leadertabbg leaderbigbg w-100vw h-100vh overflow-y-scroll leader">
    {switch data->Array.length == 0 {
    | true =>
      <>
        <div className="h-42vh" />
        <Loading label="data..." />
      </>
    | false =>
      <table
        className="border-collapse text-dark-600 font-anon table-fixed tablewidth:mx-8 lg:mx-16 desk:mx-32"
      >
        <caption
          className="my-6 relative text-4xl md:(my-12 text-5xl) desk:(my-18 text-6xl) font-fred font-bold text-shadow-lead"
        >
          <Button
            onClick={_ => {
              setLeaderData(_ => [])
              Route.push(Lobby)
            }}
            className="cursor-pointer font-over text-5xl bg-transparent absolute left-10"
          >
            {React.string("←")}
          </Button>
          {React.string("Leaderboard")}
        </caption>
        <colgroup>
          {[Name, Wins, Points, Games, WinPercentage, PointsPerGame]
          ->Array.map(c =>
            <col
              key={(c :> string)}
              className={switch sortedField == c {
              | true => "bg-stone-100/17"
              | false => ""
              }}
            />
          )
          ->React.array}
        </colgroup>
        <thead className="">
          <tr>
            {[
              ("min-w-104px left-0 z-10", "name", onClick(Name, nameDir, setNameDir), Name),
              ("min-w-64px", "wins", onClick(Wins, winDir, setWinDir), Wins),
              ("min-w-80px", "points", onClick(Points, ptsDir, setPtsDir), Points),
              ("min-w-72px", "games", onClick(Games, gamesDir, setGamesDir), Games),
              (
                "min-w-72px",
                "win %",
                onClick(WinPercentage, winPctDir, setWinPctDir),
                WinPercentage,
              ),
              ("min-w-80px", "pts/gm", onClick(PointsPerGame, ppgDir, setPPGDir), PointsPerGame),
            ]
            ->Array.map(c => {
              let (cn, btnText, oc, field) = c
              <th key=btnText className={"sticky top-0 h-8 bg-amber-300 w-16.667vw " ++ cn}>
                <Button
                  onClick={_ => oc}
                  className={"bg-transparent cursor-pointer text-dark-600 text-base font-anon font-bold w-full h-8" ++ if (
                    sortedField == field
                  ) {
                    ` relative ${arrowClass} after:(text-2xl font-over absolute)`
                  } else {
                    ""
                  }}
                >
                  {React.string(btnText)}
                </Button>
              </th>
            })
            ->React.array}
          </tr>
        </thead>
        <tbody>
          {data
          ->Array.mapWithIndex(({name, wins, points, games, winPct, ppg}, i) => {
            <tr
              className={switch name == playerName {
              | true => "text-center bg-blue-200/66 h-8 uppercase italic"
              | false => "text-center odd:bg-stone-100/16 h-8"
              }}
              key={`${name}${Int.toString(i)}`}
            >
              <th className="sticky left-0 bg-amber-200"> {React.string(name)} </th>
              <td className=""> {React.string(Int.toString(wins))} </td>
              <td className=""> {React.string(Int.toString(points))} </td>
              <td className=""> {React.string(Int.toString(games))} </td>
              <td className="">
                {switch winPct == 0. || winPct == 1. {
                | true => React.string(Float.toFixed(winPct, ~digits=2))
                | false => React.string(Float.toFixed(winPct))
                }}
              </td>
              <td className=""> {React.string(Float.toFixed(ppg))} </td>
            </tr>
          })
          ->React.array}
          <tr className="h-50vh" />
        </tbody>
      </table>
    }}
  </div>
}
