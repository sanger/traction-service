# frozen_string_literal: true

module Pacbio
    # Pacbio::WellPool
    # A well can contain many pools
    # A pool can belong in many wells
    class WellPool < ApplicationRecord
      belongs_to :well, class_name: 'Pacbio::Well', foreign_key: :pacbio_well_id,
                        inverse_of: :well_pools
      belongs_to :pool, class_name: 'Pacbio::Pool', foreign_key: :pacbio_pool_id,
                        inverse_of: :well_pools
    end
  end
  