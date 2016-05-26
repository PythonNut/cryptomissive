make_salt = ->
  sodium.randombytes_buf sodium.crypto_pwhash_SALTBYTES

hash = (password, salt) ->
  sodium.crypto_pwhash(
    sodium.crypto_secretbox_KEYBYTES,
    password,
    salt,
    sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE,
    sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE,
    sodium.crypto_pwhash_ALG_DEFAULT
  )

make_nonce  = ->
  sodium.randombytes_buf(sodium.crypto_secretbox_NONCEBYTES)

encrypt = (message, nonce, key) ->
  sodium.crypto_secretbox_easy(message, nonce, key)

decrypt = (ciphertext, nonce, key) ->
  sodium.crypto_secretbox_open_easy(ciphertext, nonce, key)

edit = ->
  $ 'body' .html($ '#editor_form' .html!)
  $('#editor').summernote(height: $(window).height())

$ -> edit!
