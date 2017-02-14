function hash (text) {
  var obj = new jsSHA(text, "TEXT");
  text = obj.getHash("SHA-512", "B64");
  return text;
}

function message_setter (message){
  var messages = document.getElementById("messages");
  messages.className = "fading_out";
  setTimeout(function () {
    messages.innerHTML = message;
    messages.className = "fading_in";
  }, 300);
}

function hashrounds (text, rounds, message, callback) {
  var result = text, progress, progressbar, messages, hashviewer;
  var i = 0;
  progressbar = document.getElementById("progress");
  messages = document.getElementById("messages");
  // hashviewer = document.getElementById("hash");
  message_setter(message);

  function doChunk () {
    progress = Math.ceil(i/rounds * 100);
    progressbar.value = progress;
    // hashviewer.className = "hash";
    // hashviewer.innerHTML = result.substring(1,32);
    for (var k = 0; k < 100; k++) {
      result = hash(result);
      i++;
    }
    if (i < rounds) {
      setTimeout(doChunk,1);
    } else {
      // hashviewer.className = "";
      // hashviewer.innerHTML = "This is a CryptoMissive.";
      callback(result);
    }
  }
  return doChunk();
}

function encrypt(text, password, callback) {
  hashrounds(password, 9000, "Encrypting plaintext...", function (key){
    return callback(GibberishAES.enc(text, key));
  });
}

function decrypt(text, password, callback) {
  hashrounds(password, 9000, "Password valid. Decrypting...", function (key) {
    return callback(GibberishAES.dec(text, key));
  });
}

function verify_key(password, checksum, callback) {
  hashrounds(password, 10000, "Verifying password...", function (key) {
    return callback(key == checksum);
  });
}

function make_checksum(password, callback) {
  hashrounds(password, 10000,"Making checksum...", callback);
}

var body, ciphertext;
function main_loop() {
  var ciphertext_container;
  body = document.getElementsByTagName("body")[0];
  ciphertext_container = document.getElementById("ciphertext");
  ciphertext = ciphertext_container.innerHTML.replace(/\s/g, "") ;
  body.innerHTML = document.getElementById("password_form").innerHTML;
}

window.onload = main_loop;
function crypto_loop (){
  var upassword, checksum, progressbar, messages;
  password = document.getElementById("password").value.trim();
  checksum = document.getElementById("password_signature").innerHTML.trim();

  messages = document.getElementById("messages");
  progressbar = document.getElementById("progress");
  verify_key(password, checksum, function (result) {
    if (result) {
      decrypt(ciphertext,password, function (plaintext) {
        body.innerHTML = plaintext;
      });
    } else {
      progressbar.value = 0;
      message_setter("Incorrect password. Please try again.");
    }
  });
}