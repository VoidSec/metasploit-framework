# -*- coding: binary -*-

module Rex
  module Proto
    module Kerberos
      module Model
        class AuthorizationData < Element

          include Rex::Proto::Kerberos::Crypto::Rc4Hmac

          # @!attribute elements
          #   @return [Hash{Symbol => <Fixnum, String>}] The type of the authorization data
          #   @option [Fixnum] :type
          #   @option [String] :data
          attr_accessor :elements

          def decode(input)
            raise ::RuntimeError, 'Authorization Data decoding not supported'
          end

          # Encodes a Rex::Proto::Kerberos::Model::AuthorizationData into an ASN.1 String
          #
          # @return [String]
          def encode
            seqs = []
            elements.each do |elem|
              elems = []
              type_asn1 = OpenSSL::ASN1::ASN1Data.new([encode_type(elem[:type])], 0, :CONTEXT_SPECIFIC)
              elems << type_asn1
              data_asn1 = OpenSSL::ASN1::ASN1Data.new([encode_data(elem[:data])], 1, :CONTEXT_SPECIFIC)
              elems << data_asn1
              seqs << OpenSSL::ASN1::Sequence.new(elems)
            end

            seq = OpenSSL::ASN1::Sequence.new(seqs)

            seq.to_der
          end

          # Encrypts the Rex::Proto::Kerberos::Model::AuthorizationData
          #
          # @param etype [Fixnum] the crypto schema to encrypt
          # @param key [String] the key to encrypt
          # @return [String] the encrypted result
          def encrypt(etype, key)
            data = self.encode

            res = ''
            case etype
            when KERB_ETYPE_RC4_HMAC
              res = encrypt_rc4_hmac(data, key, 5)
            else
              raise ::RuntimeError, 'EncryptedData schema is not supported'
            end

            res
          end


          private

          # Encodes the type
          #
          # @return [OpenSSL::ASN1::Integer]
          def encode_type(type)
            bn = OpenSSL::BN.new(type)
            int = OpenSSL::ASN1::Integer(bn)

            int
          end

          # Encodes the data
          #
          # @return [OpenSSL::ASN1::OctetString]
          def encode_data(data)
            OpenSSL::ASN1::OctetString.new(data)
          end
        end
      end
    end
  end
end