dom = void
$ ->
  dom := document.implementation.createHTMLDocument("");
  dom.documentElement.innerHTML = document.documentElement.innerHTML
  m.module(document.body, CryptoMissive);
