# frozen_string_literal: true

module Mutations
  # Mutation base class for COVID run mutations.
  class BaseCovidRunMutation < BaseMutation
    protected

    def send_messages(run:)
      Messages.publish(run, Pipelines.ont.message)
    end
  end
end
