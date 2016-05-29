#Written by Jon Hayase
#pythonnut@gmail.com
#Last updated by Tai Groot
#tai@frelancelot.com
#May 29, 2016

import hashlib
import base64
import sys
import subprocess
import getpass

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
def displayHelp():
  print("This program requires between one and three arguments, provided in any order.")
  print("\nIf only one argument is provided, the program will assume it is the infile \nand prompt you for a key, then export your encrypted file to \"encryptedFile.html.\"")
  print("\nIf you wish to provide an outfile or key via the command line, use flags to \nspecify which is the file and which is the key:")
  print("\n\nFor outfiles:\t--outfile\t--out\t-o")
  print("For infiles:\t--infile\t--in\t-i")
  print("For keys:\t--key\t\t-k\n")

if __name__ == "__main__":
  needsKey = True
  outfile = "encryptedFile.html"
  if len(sys.argv) < 2:
    print("Requires input file, run 'python3 cyrptomissive_generator.py --help' if you're stuck.")
    sys.exit(1)
  elif len(sys.argv)==2:
    if sys.argv[1] == "--help":
      displayHelp()
      sys.exit(1)
    else:
      infile = sys.argv[1]
  for i in range(1,len(sys.argv)-1):
   if sys.argv[i][0] == '-':
      if sys.argv[i][1]=='-':
        if sys.argv[i] == "--infile" or sys.argv[i] == "--in":
          infile = sys.argv[i+1]
        if sys.argv[i] == "--outfile" or sys.argv[i] == "--out":
          outfile == sys.argv[i+1]
        if sys.argv[i] == "--key":
          key = sys.argv[i+1]
          needsKey = False
      elif sys.argv[i] == "-k":
        needsKey = False
        key = sys.argv[i+1]
      elif sys.argv[i] == "-i":
        infile = sys.argv[i+1]
      elif sys.argv[i] == "-o":
        outfile = sys.argv[i+1]
  
 

  print("encrypting {} → {}...".format(infile, outfile))

  if needsKey:
    key1 = getpass.getpass("Please type a secret key: ")
    key2 = getpass.getpass("Please re-enter your key: ")
    if key1 == key2:
      print("Keys match.")
      key = key1
    else:
      print("Keys do not match")
      sys.exit(1)

  generate_cryptomissive(infile, outfile, key)
  print("done.")
