
require 'socket'
require 'openssl'
require 'base64'
require 'ostruct'


class Client
  attr_reader :socket, :certificate, :aes
  def initialize
    @socket = TCPSocket.new 'localhost', 3000
    @secure = false
  end

  def run
    loop do
      msg = gets.chomp
      next if msg.empty?
      send_line(msg)

      case msg
      when "gosecure" then make_secure
      when "exit"     then socket.close; return
      else
        puts recv_line
      end
    end
  end

  def send_line(line)
    if secure?
      line = aes.cipher.encrypt.update(line) + aes.cipher.final
      puts Base64.strict_encode64(line)
      socket.puts Base64.strict_encode64(line)
    else
      socket.puts line
    end
  end

  def recv_line
    line = socket.gets
    if secure?
      line = Base64.strict_decode64 line.chomp('')
      aes.decipher.decrypt.update(line) + aes.decipher.final
    else
      line
    end
  end

  def make_secure
    recv_cert
    send_aes_key
  end

  def recv_cert
    cert_data = ""
    loop do
      cert_line = recv_line
      cert_data += cert_line
      break if cert_line.include?("END CERTIFICATE")
    end
    @certificate = OpenSSL::X509::Certificate.new cert_data
  end

  def public_encrypt(line)
    Base64.strict_encode64 certificate.public_key.public_encrypt(line)
  end

  def send_aes_key
    @aes = OpenStruct.new(
      :cipher   => OpenSSL::Cipher::AES128.new(:CBC).encrypt,
      :decipher => OpenSSL::Cipher::AES128.new(:CBC).decrypt
    )
    send_line public_encrypt(@aes.decipher.key = @aes.cipher.random_key)
    send_line public_encrypt(@aes.decipher.iv = @aes.cipher.random_iv)
    @secure = true
  end

  def secure?
    @secure
  end
end


Client.new.run
