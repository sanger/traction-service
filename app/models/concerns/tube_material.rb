# frozen_string_literal: true

# TubeMaterial -- A material that is contained in a tube.
# This is here to support legacy features of Pacbio and Saphyr
# after Containers were introduced as a concern.
module TubeMaterial
  extend ActiveSupport::Concern
  include Material

  included do
    def tube
      return nil unless container.is_a?(Tube)

      container
    end
  end
end
