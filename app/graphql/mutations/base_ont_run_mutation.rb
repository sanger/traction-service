# frozen_string_literal: true

module Mutations
  # Mutation base class for ONT run mutations.
  class BaseOntRunMutation < BaseMutation
    protected

    def send_messages(resolved_run:)
      Messages.publish(resolved_run, Pipelines.ont.message)
    end
  end
end
