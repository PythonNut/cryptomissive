CryptoMissive = {}

CryptoMissive.model = class
  ->
    @message = m.prop 'a default message'
    @hash_result = m.prop '<no hash result>'
    @crypto_worker = void

  init_worker: ->
    sodium_source = $ '#sodium_source' .html!
    deferred = m.deferred!
    @crypto_worker = operative do
      sodium_source: sodium_source
      init: (callback) ->
        require = (name) ->
          randomBytes: (nbytes) -> [0, 0, 0, 0]
        full_source = btoa "var require = #{require.toString!};" + sodium_source
        importScripts 'data:text/javascript;charset=utf-8;base64,' + full_source
        callback!

      hash: (password, salt, callback) ->
        callback @sodium.crypto_pwhash do
          @sodium.crypto_secretbox_KEYBYTES
          password
          salt
          @sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE
          @sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE
          @sodium.crypto_pwhash_ALG_DEFAULT

    @crypto_worker.init -> deferred.resolve!
    deferred.promise

  make_salt: ->
    sodium.randombytes_buf sodium.crypto_pwhash_SALTBYTES

  make_nonce: ->
    sodium.randombytes_buf sodium.crypto_secretbox_NONCEBYTES

  derive_key_argon2: (password, salt) ->
    deferred = m.deferred!
    @crypto_worker.hash password, salt, (result) ->
      deferred.resolve result
    return deferred.promise

  encrypt_salsa20: (message, nonce, key) ->
    sodium.crypto_secretbox_easy message, nonce, key

  decrypt_salsa20: (ciphertext, nonce, key) ->
    sodium.crypto_secretbox_open_easy ciphertext, nonce, key
