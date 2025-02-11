# frozen_string_literal: true

# A portion of a sample that is used for a library, sample or pool.
# An aliquot can be a primary aliquot or a derived aliquot.
# An aliquot can be used to track volumes and concentrations of samples.
class Aliquot < ApplicationRecord
  include Uuidable

  enum :state, { created: 0, used: 1 }
  enum :aliquot_type, { primary: 0, derived: 1 }

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

  scope :filter_by_publishable, lambda {
    where(used_by_type: 'Pacbio::Well')
      .or(where(source_type: 'Pacbio::Pool',
                aliquot_type: 'primary'))
      .or(where(source_type: 'Pacbio::Library',
                aliquot_type: 'primary'))
      .or(where(source_type: 'Pacbio::Request',
                used_by_type: 'Pacbio::Library', aliquot_type: 'derived'))
  }

  # Returns a list of all the aliquots that are publishable.
  def self.publishable
    [].tap do |aliquots|
      filtered_aliquots = filter_by_publishable.to_a
      aliquots.concat(filtered_aliquots)
      aliquots.concat(used_by_well_library_aliquots(filtered_aliquots))
    end
  end

  # Find aliquots from a Pacbio::Pool used by a Pacbio::Well and add their source's
  # used aliquots if from a Pacbio::Library
  def self.used_by_well_library_aliquots(aliquots)
    well_aliquots = aliquots.select do |aliquot|
      aliquot.source_type == 'Pacbio::Pool' && aliquot.used_by_type == 'Pacbio::Well'
    end
    [].tap do |library_aliquots|
      well_aliquots.each do |aliquot|
        library_aliquots.concat(aliquot.source.used_aliquots.select do |used_aliquot|
          used_aliquot.source_type == 'Pacbio::Library'
        end)
      end
    end
  end

  # Returns the tag set for the aliquot
  # If the tag_set is nil, it returns a NullTagSet
  def tag_set
    super || NullTagSet.new
  end

  # SAMPLE SHEET GENERATION
  # The following methods are used to generate the sample sheet for the Aliquot

  # Checks if the aliquot is tagged.
  # An aliquot is considered tagged if it has a non-nil and non-empty tag.
  # @return [Boolean] Returns true if the aliquot is tagged, false otherwise.
  def tagged?
    # This feels like a bit of a hack but I wasn't exactly sure where the best place to
    # it. I tried to follow the sample sheet behaviour but got lost.
    # it looks like the only place this is used is in the sample sheet generation
    return false if tag.nil?

    tag_set.default_sample_sheet_behaviour?
  end

  # Generic method used by pacbio sample sheet generation to
  # determine whether the data is a collection or not.
  # Assuming false is a simplification used previously for sample-sheets
  def collection?
    false
  end

  # Sample bio Name field
  def bio_sample_name
    return '' if tag_set.hidden_sample_sheet_behaviour?

    source.sample_name || ''
  end

  # Returns the formatted bio sample name.
  # Replaces all colons (:) in the bio sample name with hyphens (-).

  def formatted_bio_sample_name
    bio_sample_name.gsub(':', '-')
  end

  # Barcode Name field
  # Deprecated as of SMRT-Link v13.0
  # See https://www.pacb.com/wp-content/uploads/SMRT-Link-Release-Notes-v13.0.pdf
  def barcode_name
    return if tag_set.hidden_sample_sheet_behaviour?

    "#{tag.group_id}--#{tag.group_id}"
  end

  # Sample Adapter field
  # The same adapter is used for both left and right, see same_barcodes_on_both_ends_of_sequence
  # Returns nil if the tag is nil
  def adapter
    tag&.group_id
  end
end
