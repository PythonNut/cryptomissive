$ !-> $ 'body' .html($ '#main_splash' .html!)

make_salt = ->
  sodium.randombytes_buf sodium.crypto_pwhash_SALTBYTES

hash = (password, salt) ->
  key = sodium.randombytes_buf sodium.crypto_box_SEEDBYTES
  s = sodium.from_string s
  sodium.crypto_pwhash(
    key.length,
    password,
    salt,
    sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE,
    sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE,
    sodium.crypto_pwhash_ALG_DEFAULT
  )

hash "a", make_salt!
