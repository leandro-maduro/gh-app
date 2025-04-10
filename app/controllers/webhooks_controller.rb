# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :authenticate

  def incoming
    event = JSON.parse(request.body.read, symbolize_names: true)

    return head :ok if skip?(event)

    ProcessEventsJob.perform_later(event)

    head :ok
  end

  private

  def authenticate
    signing_secret = Rails.application.credentials.dig(:github, :webhooks, :secret)

    SignatureVerifier.verify!(request.body.read, request.headers, signing_secret)
  rescue SignatureVerifier::InvalidSignatureError
    head(:unauthorized)
  end

  def skip?(event)
    return false if ProcessEventsJob::ACTIONS.keys.include?(event[:action])

    Rails.logger.info("Skipping unsupported event: #{request.headers['X-Github-Event']}.#{event[:action]}")

    true
  end
end
