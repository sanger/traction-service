# frozen_string_literal: true

module Mutations
  # Mutation base class for COVID run mutations.
  class BaseCovidRunMutation < BaseMutation
    protected

    def send_messages(run:)
      run.flowcells.each do |flowcell|
        Messages.publish(flowcell.library.requests, Pipelines.ont.covid.message)
      end
    end
  end
end
