# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignatureVerifier do
  subject(:verifier) { described_class }

  let(:payload) { 'Hello, World!' }
  let(:secret) { "It's a Secret to Everybody" }
  let(:headers) do
    { 'X-Hub-Signature-256' => 'sha256=757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17' }
  end

  describe '.verify!' do
    subject(:verify!) { verifier.verify!(payload, headers, secret) }

    context 'when payload has not been tampered with' do
      it 'does not raise an error' do
        expect { verify! }.not_to raise_error
      end
    end

    context 'when payload has been tampered with' do
      let(:payload) { 'my_new_payload' }

      it 'raises an error' do
        expect { verify! }.to raise_error(described_class::InvalidSignatureError, described_class::INVALID_SIGNATURE)
      end
    end
  end
end
