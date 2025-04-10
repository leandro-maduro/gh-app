# frozen_string_literal: true

module Issues
  class Opened
    ESTIMATION_REGEX = /Estimate:\s*\d+\s+day(s)?/i
    MESSAGE = '👋 Please add an estimate in the format `Estimate: X days` to this issue.'

    def initialize(event)
      @action = event[:action]
      @body = event.dig(:issue, :body).to_s
      @installation_id = event.dig(:installation, :id)
      @owner = event.dig(:repository, :owner, :login)
      @repository_name = event.dig(:repository, :name)
      @issue_number = event.dig(:issue, :number)
    end

    def call
      return unless opened?
      return if body.match?(ESTIMATION_REGEX)

      github_client.add_comment("#{owner}/#{repository_name}", issue_number, MESSAGE)
    end

    class << self
      def call(event)
        new(event).call
      end
    end

    private

    attr_reader :action, :body, :installation_id, :owner, :repository_name, :issue_number

    def opened?
      action == 'opened'
    end

    def github_client
      @github_client ||= begin
        app_client = Octokit::Client.new(bearer_token: jwt_token)

        token_response = app_client.create_app_installation_access_token(installation_id)
        Octokit::Client.new(access_token: token_response[:token])
      end
    end

    def jwt_token
      private_key = OpenSSL::PKey::RSA.new(Rails.application.credentials.dig(:github, :private_key))

      JWT.encode(jwt_payload, private_key, 'RS256')
    end

    def jwt_payload
      {
        iat: Time.now.to_i,
        exp: Time.now.to_i + (10 * 60),
        iss: Rails.application.credentials.dig(:github, :app_id)
      }
    end
  end
end
