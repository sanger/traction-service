# frozen_string_literal: true

module Mutations
  # Mutation base class for COVID run mutations.
  class BaseCovidRunMutation < BaseMutation
    protected

    def send_messages(run:)
      resolved_run = Ont::Run.includes(flowcells: { library: { requests: { tags: :tag_set } } })
                             .find_by(id: run.id)
      Messages.publish(resolved_run, Pipelines.ont.message)
    end
  end
end
