CryptoMissive.controller = class
  ->
    @model = new CryptoMissive.model!
    @message = @model.message
    @hash_result = @model.hash_result
    @crypto_worker_ready = m.prop false
    @crypto_worker_running = m.prop false
    @model.init_worker!
      .then ~>
        console.log "Crypto engine initialized"
        @crypto_worker_ready true
        m.redraw!
    @hash = ~>
      console.log @message!
      @crypto_worker_running true
      @model.derive_key_argon2 @message!, @model.make_salt!
        .then (result) ~>
          @hash_result sodium.to_base64 result
          @crypto_worker_running false
          m.redraw!
