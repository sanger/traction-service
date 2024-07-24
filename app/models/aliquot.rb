# frozen_string_literal: true

# Aliquot
# A portion of a sample that is used for a library, sample or pool
# An aliquot can be a primary aliquot or a derived aliquot
# An aliquot can be used to track volumes and concentrations of samples
class Aliquot < ApplicationRecord
  include SampleSheet::Aliquot
  include Uuidable

  enum state: { created: 0, used: 1 }
  enum aliquot_type: { primary: 0, derived: 1 }

  belongs_to :tag, optional: true
  has_one :tag_set, through: :tag
  belongs_to :source, polymorphic: true
  # Used to identify where a derived aliquot has been used
  belongs_to :used_by, polymorphic: true, optional: true

  # These are the associations that are used to identify the source of the aliquot
  # These are required for json api resources to understand the polymorphic relationships
  belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :source_id, optional: true,
                       inverse_of: :used_aliquots
  belongs_to :library, class_name: 'Pacbio::Library', foreign_key: :source_id, optional: true,
                       inverse_of: :used_aliquots
  belongs_to :pool, class_name: 'Pacbio::Pool', foreign_key: :source_id, optional: true,
                    inverse_of: :used_aliquots

  # currently I have set these to be validated but not sure
  # as library only validates when a run is created
  # maybe we need to do this when the state is set to used?
  # requests currently dont support these fields so we skip validation on primary aliquots
  # we dont validate insert size as it may not be known at the time of creation
  validates :volume, :concentration, :template_prep_kit_box_barcode,
            presence: true,
            unless: -> { source.is_a?(Pacbio::Request) && aliquot_type == 'primary' }
  validates :volume, :concentration,
            :insert_size, presence: true, on: :run_creation
  validates :volume, :concentration, :insert_size,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  delegate :is_a?, to: :used_by, prefix: true

  def sample_sheet_behaviour
    SampleSheetBehaviour.get(tag_set&.sample_sheet_behaviour || :untagged)
  end

  # Checks if the aliquot is tagged.
  #
  # An aliquot is considered tagged if it has a non-nil and non-empty tag.
  #
  # @return [Boolean] Returns true if the aliquot is tagged, false otherwise.
  def tagged?
    tag.present?
  end

  # Generic method used by pacbio sample sheet generation to
  # determine whether the data is a collection or not.
  # Assuming false is a simplification used previously for sample-sheets
  def collection?
    false
  end
end
