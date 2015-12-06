
require 'socket'
require 'openssl'
require 'base64'
require 'ostruct'


class Server
  attr_reader :client, :certificate, :pkey, :aes
  def initialize(cert_path, key_path)
    s = TCPServer.new 3000

    @client = s.accept
    @certificate = OpenSSL::X509::Certificate.new File.read(cert_path)
    @pkey = OpenSSL::PKey::RSA.new File.read(key_path)
    @secure = false
  end

  def run
    loop do
      case line = recv_line.chomp
      when "gosecure" then make_secure
      when "exit" then client.close; return
      when "ping" then send_line("pong")
      when /^echo/ then send_line(line.sub('echo', '').lstrip)
      else
        puts line
        send_line("Dunno such command")
      end
    end
  end

  def send_line(line)
    if secure?
      line = aes.cipher.encrypt.update(line) + aes.cipher.final
      client.puts Base64.strict_encode64(line)
    else
      client.puts line
    end
  end

  def recv_line
    line = client.gets
    if secure?
      line = Base64.strict_decode64 line.chomp('')
      aes.decipher.decrypt.update(line) + aes.decipher.final
    else
      line
    end
  end

  def make_secure
    send_cert
    recv_aes_key
  end

  def send_cert
    send_line(certificate.to_pem)
  end

  def private_decrypt(line)
    pkey.private_decrypt Base64.strict_decode64(line.chomp)
  end

  def recv_aes_key
    @aes = OpenStruct.new(
      :cipher   => OpenSSL::Cipher::AES128.new(:CBC).encrypt,
      :decipher => OpenSSL::Cipher::AES128.new(:CBC).decrypt
    )

    @aes.cipher.key = @aes.decipher.key = private_decrypt recv_line
    @aes.cipher.iv = @aes.decipher.iv = private_decrypt recv_line
    @secure = true
  end

  def secure?
    @secure
  end
end


Server.new("certs/user.crt", "certs/user.key").run
