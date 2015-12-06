
# Information Security Lab 6.

### X.509 Certificates and their application

The objective of this laboratory work is to setup a Certificate Authority, use it to issue a certificate and then use the later to establish an HTTPS-like secure communication between a client and server application.

##### Root CA

Creating a root Certificate Authority is just a matter of creating a self-signed X.509 certificate. The `openssl` program has all the necessary tools to achieve the task.

```bash
openssl req -x509 -newkey rsa:2048 -keyout root-ca.key -out root-ca.crt -days 10000 -nodes
```

The command above will generate an RSA keypair and will ask for various information (Country, Common Name, Email, etc..) which is to be embedded in the certificate. After all questions are answered, the command will yield a self-signed X.509 certificate valid for 10000 days as well as the private key associated with it. The `-nodes` specifies that output data should not be encrypted with a password (this is to make the process easier for this assignment).


##### Issuing Certificates

In order to issue a certificate, it is necessary to obtain a Certificate Signing Request (CSR). The following command will generate a private key and a CSR. In the process it will ask the same questions as in the case with the command described above.

```bash
openssl req -newkey rsa:2048 -keyout user.key -out user.csr -nodes
```

Now, in order to sign the created request the `openssl ca` command will be used. However, there are some requirements to be met for this command to work, specifically, it is necessary to provide a configuration file with information about the Certificate Authority. Here is such a file based on the one provided on the [page of the 'openssl ca' program](https://www.openssl.org/docs/manmaster/apps/ca.html):

```ini
[ ca ]
default_ca      = CA_default           # The default ca section

[ CA_default ]

dir            = ./root-ca             # top dir
database       = $dir/index.txt        # index file.
new_certs_dir  = $dir/newcerts         # new certs dir

certificate    = root-ca.crt           # The CA cert
serial         = $dir/serial           # serial no file
private_key    = root-ca.key           # CA private key
RANDFILE       = $dir/private/.rand    # random number file

default_days   = 365                   # how long to certify for
default_crl_days= 30                   # how long before next CRL
default_md     = md5                   # md to use

policy         = policy_any            # default policy
email_in_dn    = no                    # Don't add the email into cert DN

name_opt       = ca_default            # Subject name display option
cert_opt       = ca_default            # Certificate display option
copy_extensions = none                 # Don't copy extensions from request

[ policy_any ]
countryName            = supplied
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional
```

For the sake of this assignment, all the paths are specified relative to the current directory. Note that it is also important that the following files and folders exist:

- `./root-ca/` - the root folder of the CA files
- `./root-ca/newcerts/` - a folder where new certificates will be copied
- `./root-ca/index.txt` - the database of issued certificates, MUST be empty initially
- `./root-ca/serial` - the file containing the serial number for the next certificate, it should contain `01` in the beginning, after that it will be automatically incremented

Now that all is configured, it is possible to sign the request created earlier:

```bash
openssl ca -config root-ca.cnf -in user.csr -out user.crt
```

##### X.509 For Secure Communication

This laboratory work includes a simple Ruby client-server application to showcase the use of certificates in real situation. The client can issue to the server several simple commands like 'echo', 'ping' and 'exit'. At startup all the communication is in plain text. However, if the client sends the `gosecure` command, a proceture is started, similar to establishing an HTTPS connection, but simplified. The steps are as follows:

1. The client issues the `gosecure` command
2. The server sends its certificate ('user.crt')
3. The client extracts the public key out of the certificate
4. A key and an initialization vector are created for a AES-128-CBC cipher
5. This key and IV are encrypted using the public key and send to the server
6. The server decrypts the message using its private key and uses the contents to also create a cipher
7. From now on, all the communication is encrypted using the obtained cipher

The algorithm described above only illustrates the concept and doesn't reflect all the intricate things that happen in a real TLS handshake. For example, the encryption key is not transmited this way from the client to the server, instead, the parties generate and exchange random sequences that are later used to construct the so called master key for further encryption.
