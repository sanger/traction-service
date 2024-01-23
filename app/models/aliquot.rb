# frozen_string_literal: true

# Aliquot
# A portion of a sample that is used for a library, sample or pool
# An aliquot can be a primary aliquot or a derived aliquot
# An aliquot can be used to track volumes and concentrations of samples
class Aliquot < ApplicationRecord
  enum state: { created: 0, used: 1 }
  enum aliquot_type: { primary: 0, derived: 1 }

  belongs_to :tag, optional: true
  belongs_to :source, polymorphic: true
  belongs_to :well, class_name: 'Pacbio::Well', optional: true, foreign_key: :pacbio_well_id,
                    inverse_of: :aliquots

  # currently I have set these to be validated but not sure
  # as library only validates when a run is created
  # maybe we need to do this when the state is set to used?
  # we also need to consider that aliquot can be attached to a sample
  # which will not have a barcode or insert size
  validates :volume, :concentration, :template_prep_kit_box_barcode, :insert_size, presence: true
  validates :volume, :concentration, :insert_size,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
