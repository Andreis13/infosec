
require 'openssl'
require 'base64'
require 'securerandom'

module ProductKey
  SALT_LENGTH = 20

  def self.create(private_key, keyword="secret")
    priv_key = OpenSSL::PKey::RSA.new private_key
    s = keyword + SecureRandom.random_bytes(SALT_LENGTH)
    Base64.encode64(priv_key.private_encrypt(s))
  end

  def self.check(reg_key, public_key, keyword="secret")
    pub_key = OpenSSL::PKey::RSA.new public_key
    decrypted = pub_key.public_decrypt(Base64.decode64(reg_key))
    decrypted.start_with?('secret')
  rescue
    return false
  end
end
