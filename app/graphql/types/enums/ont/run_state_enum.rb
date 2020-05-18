# frozen_string_literal: true

module Types
  module Enums
    module Ont
      # An enum containing Ont Run states.
      class RunStateEnum < BaseEnum
        value 'PENDING', 'The run is awaiting to be started.', value: 'pending'
        value 'STARTED', 'The run is currently running but not yet completed.', value: 'started'
        value 'COMPLETED', 'The run has completed.', value: 'completed'
        value 'CANCELLED', 'The run has been cancelled.', value: 'cancelled'
      end
    end
  end
end
