type authSubroute =
  | Lobby
  | Play({play: string})
  | Unknown

type t =
  | Home
  | Leaderboard
  | SignIn
  | Auth({subroute: authSubroute})
  | NotFound

let stringToAuthSubroute = l =>
  switch l {
  | list{"lobby"} => Auth({subroute: Lobby})
  | list{"play", gameno} => Auth({subroute: Play({play: gameno})})
  | _ => Auth({subroute: Unknown})
  }

let authSubrouteToString = a =>
  switch a {
  | Lobby => "lobby"
  | Play({play}) => `play/${play}`
  | Unknown => ""
  }

let urlStringToType = (url: RescriptReactRouter.url) =>
  switch url.path {
  | list{} => Home
  | list{"leaderboard"} => Leaderboard
  | list{"signin"} => SignIn
  | list{"auth", ...subroutes} => stringToAuthSubroute(subroutes)
  | _ => NotFound
  }

let typeToUrlString = t =>
  switch t {
  | Home => "/"
  | Leaderboard => "/leaderboard"
  | SignIn => "/signin"
  | Auth({subroute}) => `/auth/${authSubrouteToString(subroute)}`
  | NotFound => ""
  }

let useRouter = () => urlStringToType(RescriptReactRouter.useUrl())
let replace = route => route->typeToUrlString->RescriptReactRouter.replace
let push = route => route->typeToUrlString->RescriptReactRouter.push
