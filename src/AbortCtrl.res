let abortCtrl = comp => {
  open Fetch
  let basetime = 10
  let millis = basetime * 1_000
  let controller = AbortController.make()

  let timeoutSignal = AbortSignal.timeout(millis)
  let manualSignal = AbortController.signal(controller)

  let timeoutHandler = _ =>
    Console.log(`${comp} request timed out after ${Int.toString(basetime)}s`)
  let manualHandler = _ => Console.log(`${comp} request aborted manually`)

  let signal = AbortSignal.any([timeoutSignal, manualSignal])

  AbortSignal.addEventListener(timeoutSignal, #abort(timeoutHandler), ~options={once: true, signal})
  AbortSignal.addEventListener(manualSignal, #abort(manualHandler), ~options={once: true, signal})

  (controller, signal)
}
