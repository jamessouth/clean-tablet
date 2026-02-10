@val external document: Dom.document = "document"
@scope("document") @val external cookie: string = "cookie"
@set external setCookie: (Dom.document, string) => unit = "cookie"
@send external setTime: (Date.t, Date.msSinceEpoch) => Date.t = "setTime"

let yearsMillis = Float.parseFloat("31536000000")
let name_cookie_key = "clean_tablet_username="

let setNameCookie = value => {
  let key = name_cookie_key
  let now = Date.make()
  let inAYear = Date.getTime(now) + yearsMillis
  let _ = now->setTime(inAYear)
  let expiry = now->Date.toUTCString

  document->setCookie(`${key}${value};expires=${expiry};path=/;SameSite=Strict`)
}

type return = {
  nameCookie: bool,
  setNameCookie: (bool => bool) => unit,
}

let useCookie = () => {
  let (nameCookie, setNameCookie) = React.useState(_ => None)

  React.useEffect(() => {
    Console.log("in cookie eff")

    switch cookie
    ->String.split(";")
    ->Array.find(k => k->String.trim->String.startsWith(name_cookie_key)) {
    | None => ()
    | Some(c) =>
      switch c->String.split("=")->Array.get(1) {
      | None => ()
      | Some(v) => setNameCookie(_ => Some(v))
      }
    }

    None
  }, [])

  {
    nameCookie,
    setNameCookie,
  }
}
