# frozen_string_literal: true

class PublishOntRunMessageJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    run = Ont::Run.find_by(id: run_id)
    return unless run

    Messages.publish(run, Pipelines.ont.message)
  end
end