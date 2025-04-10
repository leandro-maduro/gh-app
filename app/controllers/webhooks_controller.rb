# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :authenticate

  ACTIONS = {
    'opened' => Issues::Opened
  }.freeze

  def incoming
    event = JSON.parse(request.body.read, symbolize_names: true)
    action = ACTIONS.fetch(event[:action])

    action.call(event)
  rescue KeyError
    Rails.logger.info("Skipping event #{request.headers['X-Github-Event']}.#{action_name}")
  end

  private

  def authenticate
    signing_secret = Rails.application.credentials.dig(:github, :webhooks, :secret)

    SignatureVerifier.verify!(request.body.read, request.headers, signing_secret)
  rescue SignatureVerifier::InvalidSignatureError
    head(:unauthorized)
  end
end
