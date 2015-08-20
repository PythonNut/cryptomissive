CryptoMissive
=============

This is a simple JS wrapper for HTML that encrypts it contents. It is useful to those who already posses a secret key.


Usage
=====

Producing CryptoMissives is easy, thanks to the automated Python script.

```bash
$ git clone https://github.com/PythonNut/cryptomissive
$ cd cryptomissive
```

You will need a working copy of `openssl`, `python3` and a web browser.

Now, make your message. The format of the message is the `<body>` of an HTML document.

```bash
$ emacs plaintext.html # wonderful magic happens here, BTW
$ cat plaintext.html
Yo dude. This message be <em>secret</em>.
```

And finally, produce the _uber secret_ message of doom and destruction!

```bash
$ python cryptomissive_generator.py plaintext.html ciphertext.html
encrypting plaintext.html ⇒ ciphertext.html...
Please type a secret key: ***************
Please re-enter your key: ***************
Keys match.
done.
```

And behold! Your new messenger of secrecy has come into being! Navigate to that file in any modern web browser and see for yourself.

![screenshot](screenshot.png)
