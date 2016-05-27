CryptoMissive.view_helpers = class
  @summer_note_init = (element, init, context) ->
    if !init
      $(element).summernote!

CryptoMissive.view = (controller)->
  [m("button",
     {onclick: controller.async_task.bind @},
     controller.message!)
   m('div', {config: CryptoMissive.view_helpers.summer_note_init})]
