CryptoMissive.controller = class
  ->
    @model = new CryptoMissive.model!
    @message = ~> @model.message!
    @async_task = ~>
      @model.message "aha!"
      setTimeout (@async_task_finish.bind @), 1000

    @async_task_finish = ~>
      @model.message "done!"
      m.redraw!
