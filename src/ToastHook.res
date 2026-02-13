type toastState = Loading | None | Some(string)

let useToast = () => {
  let (showToast, setShowToast) = React.useState(_ => None)

  (showToast, setShowToast)
}
