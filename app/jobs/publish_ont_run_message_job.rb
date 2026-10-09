# frozen_string_literal: true

# Publishes a message for an Oxford Nanopore Technologies (ONT) run.
class PublishOntRunMessageJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    run = Ont::Run.find_by(id: run_id)
    return unless run

    Messages.publish(run, Pipelines.ont.message)
  end
end
