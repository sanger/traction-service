# frozen_string_literal: true

module Mutations
  # Mutation base class for COVID run mutations.
  class BaseCovidRunMutation < BaseMutation
    protected

    def send_messages(run:)
      Messages.publish(Ont::Run.resolved_query.find_by(id: run.id), Pipelines.ont.message)
    end
  end
end
