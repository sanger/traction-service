# frozen_string_literal: true

class PublishPacbioRunMessageJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    run = Pacbio::Run.find_by(id: run_id)
    return unless run

    Messages.publish(run, Pipelines.pacbio.message)
    Emq::Publisher.publish(run.aliquots_to_publish_on_run, Pipelines.pacbio, 'volume_tracking')
  end
end
