
# Information Security Lab 5.

### Registration Number Verification

The small Ruby module presented in this laboratory work represents a prototype of a system that might be used for registration number creation and verification. The method is based on public key cryptography and the algorith is as follows:

#### Creation

1. Generate a sequence of random characters/bytes
2. Concatenate it with a 'secret' keyword
3. Encrypt the obtained string using the *private* key of the company
4. Encode the result in a Base64 string and distribute it to the client

#### Verification

1. Decode the Base64 encoded registration number (string)
2. Decrypt the sequence using the *public* key embedded in the application
3. Check if the decrypted string contains the 'secret' keyword

#### In code

Product key creation:

```ruby
product_key = ProductKey.create(private_key, secret_word) # => base64 encoded string
```

Product key verification:

```ruby
ProductKey.check(product_key, public_key, secret_word) # => boolean
```

#### Notes

One may use as a secret keyword, the serial number of the product to be registered.

Of course using an interpreted language to implement such functionality makes little sense, as it make very easy for experienced people to patch the application in order to overcome the registration process. In a compiled program however, a hacker would have to take the route of disassembling the executable in order to identify and patch the region responsible for registration checking.



