@val external document: Dom.document = "document"
@scope("document") @val external cookie: string = "cookie"
@set external setCookie: (Dom.document, string) => unit = "cookie"
@send external setTime: (Date.t, Date.msSinceEpoch) => Date.t = "setTime"

let yearsMillis = Float.parseFloat("31536000000")

let getCookieValue = key => {
  cookie->String.split(";")->Array.find(k => k->String.trim->String.startsWith(key))
}

let setCookie = (name, value) => {
  let now = Date.make()
  let inAYear = Date.getTime(now) + yearsMillis
  let _ = now->setTime(inAYear)
  let expiry = now->Date.toUTCString

  document->setCookie(`${name}${value};expires=${expiry};path=/;SameSite=Strict`)
}
