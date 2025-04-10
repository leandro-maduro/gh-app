# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'ignores event' do
  it 'ignores event' do
    call

    expect(github_client).not_to have_received(:add_comment)
  end
end

RSpec.shared_examples 'leaves a comment' do
  it 'leaves a comment on the issue' do
    call

    expect(github_client)
      .to have_received(:add_comment).with('owner_login/my_repo', 1, described_class::MESSAGE).once
  end
end

RSpec.describe Issues::OpenedService do
  describe '.call' do
    subject(:call) { described_class.call(event) }

    let(:github_app_client) { instance_double(Octokit::Client) }
    let(:github_client) { instance_double(Octokit::Client) }
    let(:pkey_rsa) { instance_double(OpenSSL::PKey::RSA) }
    let(:action) { 'opened' }
    let(:body) { 'Estimate: 2 days' }
    let(:event) do
      {
        action:,
        issue: {
          number: 1,
          body:
        },
        repository: {
          name: 'my_repo',
          owner: {
            login: 'owner_login'
          }
        },
        installation: {
          id: 1
        }
      }
    end

    before do
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return(pkey_rsa)
      allow(JWT).to receive(:encode).and_return('jwt_token')
      allow(Octokit::Client).to receive(:new).with(bearer_token: anything).and_return(github_app_client)
      allow(Octokit::Client).to receive(:new).with(access_token: 'token').and_return(github_client)

      allow(github_app_client).to receive(:create_app_installation_access_token).and_return(token: 'token')
      allow(github_client).to receive(:add_comment)
    end

    context 'when action is not opened' do
      let(:action) { 'something' }

      it_behaves_like 'ignores event'
    end

    context 'when estimation is set' do
      it_behaves_like 'ignores event'
    end

    context 'when estimation is set for just one day' do
      let(:body) { 'Estimate: 1 day' }

      it_behaves_like 'ignores event'
    end

    context 'when estimation is not set' do
      context 'when body does not match the pattern' do
        let(:body) { 'something here' }

        it_behaves_like 'leaves a comment'
      end

      context 'when body is nil' do
        let(:body) { nil }

        it_behaves_like 'leaves a comment'
      end
    end
  end
end
