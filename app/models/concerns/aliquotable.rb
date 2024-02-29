# frozen_string_literal: true

# Aliquotable
module Aliquotable
  extend ActiveSupport::Concern

  included do
    has_many :aliquots, as: :source, dependent: :destroy
    has_many :used_aliquots, as: :used_by, dependent: :destroy, class_name: 'Aliquot'
    has_one :primary_aliquot, -> { where(aliquot_type: :primary) },
            as: :source, class_name: 'Aliquot',
            dependent: :destroy, inverse_of: :source
    has_many :derived_aliquots, -> { where(aliquot_type: :derived) },
             as: :source, class_name: 'Aliquot',
             dependent: :nullify, inverse_of: :source
  end
end
