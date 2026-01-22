type t =
  // public
  | Home
  | SignIn
  | Auth_Confirm(string)
  //   private
  | Landing
  | Leaderboard
  | Lobby
  | Play(string)
  //   both
  | NotFound

let urlStringToType = (url: RescriptReactRouter.url) =>
  switch url.path {
  | list{} => Home
  | list{"signin"} => SignIn
  | list{"auth", "confirm"} => Auth_Confirm(url.search)
  | list{"api", "landing"} => Landing
  | list{"api", "leaderboard"} => Leaderboard
  | list{"api", "lobby"} => Lobby
  | list{"api", "play", game} => Play(game)
  | _ => NotFound
  }

let typeToUrlString = t =>
  switch t {
  | Home => "/"
  | SignIn => "/signin"
  | Landing => "/api/landing"
  | Leaderboard => "/api/leaderboard"
  | Lobby => "/api/lobby"
  | Play(game) => `/api/play/${game}`
  | Auth_Confirm(_) | NotFound => ""
  }

let useRouter = () => urlStringToType(RescriptReactRouter.useUrl())
let replace = route => route->typeToUrlString->RescriptReactRouter.replace
let push = route => route->typeToUrlString->RescriptReactRouter.push
