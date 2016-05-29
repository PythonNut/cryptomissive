CryptoMissive.view_helpers = class
  @summer_note_init = (element, init, context) ->
    if !init
      $(element).summernote!

CryptoMissive.view = (ctrl)->
  [
    m 'input[type=text]', {onkeyup: (m.withAttr 'value', ctrl.message), value: ctrl.message!}
    m 'input[type=text]', {value: ctrl.hash_result!}
    m 'button', {onclick: ctrl.hash}, "Click me!"
    if ctrl.crypto_worker_ready!
      m 'span', "ready!"
    else
      []
    if ctrl.crypto_worker_running!
      m 'span', "running..."
    else
      []
  ]
