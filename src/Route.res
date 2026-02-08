type votp = Supabase.Auth.verifyOtpParams

type t =
  | Home // public ↓
  | SignIn(votp)
  | Landing //   private ↓
  | Leaderboard
  | Lobby
  | Play(string)
  | NotFound //   both

let urlStringToType = (url: RescriptReactRouter.url) =>
  switch url.path {
  | list{} => Home
  | list{"signin"} =>
    switch String.split(url.search, "&") {
    | [h, t] =>
      let vals = [h, t]->Array.map(s =>
        switch String.split(s, "=") {
        | [_, val] => val
        | _ => "x"
        }
      )
      let votparam: votp = {
        token_hash: vals->Array.getUnsafe(0),
        type_: switch vals->Array.getUnsafe(1) {
        | "email" => #email
        | "signup" => #signup
        | _ => #other
        },
      }
      SignIn(votparam)
    | _ =>
      SignIn({
        token_hash: "y",
        type_: #other,
      })
    }
  | list{"api", "landing"} => Landing
  | list{"api", "leaderboard"} => Leaderboard
  | list{"api", "lobby"} => Lobby
  | list{"api", "play", game} => Play(game)
  | _ => NotFound
  }

let typeToUrlString = t =>
  switch t {
  | Home => "/"
  | Landing => "/api/landing"
  | Leaderboard => "/api/leaderboard"
  | Lobby => "/api/lobby"
  | Play(game) => `/api/play/${game}`
  | SignIn(_) | NotFound => ""
  }

let useRouter = () => urlStringToType(RescriptReactRouter.useUrl())
let replace = route => route->typeToUrlString->RescriptReactRouter.replace
let push = route => route->typeToUrlString->RescriptReactRouter.push
