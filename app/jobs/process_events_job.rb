# frozen_string_literal: true

class ProcessEventsJob < ApplicationJob
  queue_as :default
  retry_on Octokit::Error

  ACTIONS = {
    'opened' => Issues::OpenedService
  }.freeze

  def perform(event)
    action = ACTIONS.fetch(event[:action])
    action.call(event)
  end
end
