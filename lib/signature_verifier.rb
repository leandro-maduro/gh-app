# frozen_string_literal: true

module SignatureVerifier
  class InvalidSignatureError < StandardError; end

  module_function

  INVALID_SIGNATURE = 'Signature is invalid'

  def verify!(payload, headers, secret)
    signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, payload)}"
    expected_signature = headers['X-Hub-Signature-256']

    raise InvalidSignatureError, INVALID_SIGNATURE unless OpenSSL.secure_compare(signature, expected_signature)
  end
end
