# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  describe 'POST /webhooks' do
    let(:params) { { action: 'opened' } }
    let(:issue_opened_service) { instance_double(Issues::OpenedService, call: true) }
    let(:headers) do
      {
        'CONTENT_TYPE' => 'application/json',
        'X-Github-Event' => 'issues'
      }
    end

    context 'with a supported event' do
      before do
        allow(SignatureVerifier).to receive(:verify!).and_return(true)
        allow(Issues::OpenedService).to receive(:new).and_return(issue_opened_service)
      end

      it 'processes event' do
        post(webhooks_path, headers:, params: params.to_json)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when event is not supported' do
      let(:params) { { action: 'closed' } }

      before do
        allow(SignatureVerifier).to receive(:verify!).and_return(true)
        allow(Rails.logger).to receive(:info)
      end

      it 'skips event' do
        post(webhooks_path, headers:, params: params.to_json)

        expect(Rails.logger).to have_received(:info).once.with('Skipping unsupported event: issues.closed')
      end
    end

    context 'when signature verification fails' do
      before { allow(SignatureVerifier).to receive(:verify!).and_raise(SignatureVerifier::InvalidSignatureError) }

      it 'returns unauthorized' do
        post(webhooks_path, headers:, params: params.to_json)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
