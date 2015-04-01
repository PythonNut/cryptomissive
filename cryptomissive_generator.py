import hashlib
import base64
import sys
import subprocess

def b64(text):
  text = text.encode('utf-8')
  return base64.b64encode(base64.b16decode(text)).decode('utf-8')


def hash(text):
  text = text.encode('utf-8')
  return b64(hashlib.sha512(text).hexdigest().upper())


def hashrounds(text, rounds):
  result = text

  # emulate the chunking in the JS version
  rounds = int((rounds - 1)/100 + 1) * 100

  for i in range(rounds):
    result = hash(result)

  return result


def make_checksum(password):
  return hashrounds(password, 10000)


def verify_key(password, checksum):
  return  make_checksum(password) == checksum


def encrypt(text, password):
  password = hashrounds(password, 9000)
  proc = subprocess.Popen(
    ["openssl", "enc", "-aes-256-cbc", "-a", "-k", password],
    shell=False,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
  )
  result = proc.communicate(input=text.encode('utf-8'))[0]
  return result.decode('utf-8')


def decrypt(text, password):
  password = hashrounds(password, 9000)
  proc = subprocess.Popen(
    ["openssl", "enc", "-d", "-aes-256-cbc", "-a", "-k", password],
    shell=False,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
  )
  result = proc.communicate(input=text.encode('utf-8'))[0]
  return result.decode('utf-8')


def generate_cryptomissive(infile, outfile, key):
  with open(infile)               as f: plaintext    = f.read()
  with open("aes.js")             as f: aes          = f.read()
  with open("sha512.js")          as f: sha512       = f.read()
  with open("cryptoengine.js")    as f: cryptoengine = f.read()
  with open("form.html")          as f: form         = f.read()
  with open("cryptomissive.html") as f: body         = f.read()

  checksum = make_checksum(key)
  ciphertext = encrypt(plaintext, key)

  js = aes + "\n" + sha512 + "\n" + cryptoengine + "\n"
  body = body.format(
    js=js ,
    checksum=checksum,
    password_form=form,
    ciphertext=ciphertext
  )

  with open(outfile, "w") as f:
    f.write(body)


if __name__ == "__main__":
  infile  = sys.argv[1]
  outfile = sys.argv[2]
  key     = sys.argv[3]
  print("encrypting {} ⇒ {}...".format(infile, outfile))
  generate_cryptomissive(infile, outfile, key)
  print("done.")
