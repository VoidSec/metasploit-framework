# -*- coding: binary -*-

module Rex
  module Proto
    module Kerberos
      module Crypto
        module Rc4Hmac
          # Decrypts the cipher using RC4-HMAC schema
          #
          # @param cipher [String] the data to decrypt
          # @param key [String] the key to decrypt
          # @param msg_type [Fixnum] the message type
          # @return [String] the decrypted cipher
          # @raise [RuntimeError] if decryption doesn't succeed
          def decrypt_rc4_hmac(cipher, key, msg_type)
            unless cipher && cipher.length > 16
              raise ::RuntimeError, 'RC4-HMAC decryption failed'
            end

            #my_key = OpenSSL::Digest.digest('MD4', Rex::Text.to_unicode(key))

            checksum = cipher[0, 16]
            data = cipher[16, cipher.length - 1]

            #k1 = OpenSSL::HMAC.digest('MD5', my_key, [msg_type].pack('V'))
            k1 = OpenSSL::HMAC.digest('MD5', key, [msg_type].pack('V'))
            k3 = OpenSSL::HMAC.digest('MD5', k1, checksum)

            cipher = OpenSSL::Cipher::Cipher.new('rc4')
            cipher.decrypt
            cipher.key = k3
            decrypted = cipher.update(data) + cipher.final

            if OpenSSL::HMAC.digest('MD5', k1, decrypted) != checksum
              raise ::RuntimeError, 'RC4-HMAC decryption failed, incorrect checksum verification'
            end

            decrypted
          end

          # Encrypts the cipher using RC4-HMAC schema
          #
          # @param data [String] the data to encrypt
          # @param key [String] the key to encrypt
          # @param msg_type [Fixnum] the message type
          # @return [String] the encrypted data
          def encrypt_rc4_hmac(data, key, msg_type)
            #my_key = OpenSSL::Digest.digest('MD4', Rex::Text.to_unicode(key))
            k1 = OpenSSL::HMAC.digest('MD5', key, [msg_type].pack('V'))

            data_encrypt = Rex::Text::rand_text(8) + data
            #data_encrypt = "\x92\xc9\x72\xcf\xe3\x51\xcc\xbf" + data
            checksum = OpenSSL::HMAC.digest('MD5', k1, data_encrypt)

            k3 = OpenSSL::HMAC.digest('MD5', k1, checksum)

            cipher = OpenSSL::Cipher::Cipher.new('rc4')
            cipher.encrypt
            cipher.key = k3
            encrypted = cipher.update(data_encrypt) + cipher.final

            res = checksum + encrypted
            res
          end
        end
      end
    end
  end
end