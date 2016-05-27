CryptoMissive = {}

CryptoMissive.model = class
  ->
    @message = m.prop 'a default message'

  make_salt: ->
    sodium.randombytes_buf sodium.crypto_pwhash_SALTBYTES

  make_nonce: ->
    sodium.randombytes_buf sodium.crypto_secretbox_NONCEBYTES

  derive_key_argon2: (password, salt) ->
    sodium.crypto_pwhash do
      sodium.crypto_secretbox_KEYBYTES
      password
      salt
      sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE
      sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE
      sodium.crypto_pwhash_ALG_DEFAULT

  encrypt_salsa20: (message, nonce, key) ->
    sodium.crypto_secretbox_easy message, nonce, key

  decrypt_salsa20: (ciphertext, nonce, key) ->
    sodium.crypto_secretbox_open_easy ciphertext, nonce, key
