type toastState = Loading | None | Some(string)

let useToast = () => {
  let (showToast, setShowToast) = React.useState(_ => Loading)

  (showToast, setShowToast)
}
