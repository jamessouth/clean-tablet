
@scope("document") @val external cookie: string = "cookie"

let getCookieValue = key => {
  let val = cookie->String.split(";")->Array.find((k) => k->String.trim->String.startsWith(key))

// switch val {
// | Some(v) => switch v->String.split("=")->Array.get(1){
//     |Some(c) => c
//     |None => ""
// }
// | None => ""
// }
  
  
  
  
}



let setCookie = (name, value, expiryInDays ) => {
  const date = new Date();
  date.setTime(date.getTime() + expiryInDays * 24 * 60 * 60 * 1000);
  const expires = `expires=${date.toUTCString()}`;
  document.cookie = `${name}${value};${expires};path=/;SameSite=Strict`;
}



