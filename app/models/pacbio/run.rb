# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    NAME_PREFIX = 'TRACTION-RUN-'

    include Uuidable
    include Stateful
    include SampleSheet::Run

    # Sequel II and Sequel I are now deprecated
    enum system_name: { 'Sequel II' => 0, 'Sequel I' => 1, 'Sequel IIe' => 2, 'Revio' => 3 }

    # before_create :generate_comment, unless: -> { wells.nil? }

    # We want to generate comments before the run was created
    # but tube barcodes aren't generated until the run is created.

    after_create :generate_name, :generate_comment

    has_many :plates, foreign_key: :pacbio_run_id,
                      dependent: :destroy, inverse_of: :run, autosave: true

    # This association creates the link to the SmrtLinkVersion. Run belongs
    # to a SmrtLinkVersion. We set the default SmrtLinkVersion for the run
    # using the class method 'default'.
    belongs_to :smrt_link_version,
               class_name: 'Pacbio::SmrtLinkVersion',
               foreign_key: :pacbio_smrt_link_version_id,
               inverse_of: :runs,
               default: -> { SmrtLinkVersion.default }

    validates :system_name, presence: true

    validates_with InstrumentTypeValidator,
                   instrument_types: Rails.configuration.pacbio_instrument_types,
                   if: lambda {
                         system_name.present?
                       }

    validates :name, uniqueness: { case_sensitive: false }

    scope :active, -> { where(deactivated_at: nil) }

    accepts_nested_attributes_for :plates, allow_destroy: true

    # This will return an empty list
    # If plate/well data is required via the run, use ?include=plates.wells
    attr_reader :plates_attributes

    # if comments are nil this blows up so add try.

    def generate_comment
      comment = wells.collect do |well|
        concentration = well.library_concentration || well.on_plate_loading_concentration
        " #{well.used_aliquots.first.source.tube.barcode} #{concentration}pM"
      end.join(' ')

      update(comments: (comments + comment))
    end

    def comments
      super || ''
    end

    # returns sample sheet csv for a Pacbio::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      configuration = pacbio_run_sample_sheet_config
      sample_sheet_class = "RunCsv::#{configuration.sample_sheet_class}".constantize
      sample_sheet = sample_sheet_class.new(object: self, configuration:)
      sample_sheet.payload
    end

    # v12 has changed to use instrument_name
    # We can't alias it as it is an enum
    def instrument_name
      system_name
    end

    # This is needed to generate the comments
    def wells
      plates.collect(&:wells).flatten
    end

    # updates the smrt link options for all of the wells in the run
    # returns the number of wells updated
    # each well is saved after the update
    # it is inefficient to save each well individually but this is not used by the UI
    # @param options [Hash] the options to update
    # @return [Integer] the number of wells updated
    def update_smrt_link_options(options)
      wells.each do |well|
        well.update_smrt_link_options(options)
      end
      wells.count
    end

    # Returns all aliquots with source_type 'Pacbio::Library' from the wells of the plates.
    # @return [Array<Aliquot>] an array of aliquots with source_type 'Pacbio::Library'
    def all_library_aliquots
      plates.flat_map do |plate|
        plate.wells.flat_map do |well|
          well.used_aliquots.select { |aliquot| aliquot.source_type == 'Pacbio::Library' }
        end
      end
    end

    private

    # We now have SMRT Link versioning
    # This allows generation of sample sheets based on the SMRT Link version
    # Each different version of SMRT Link has different columns
    # A version can be assigned to a run but changed
    # e.g. Pipelines.pacbio.sample_sheet.by_version('v10')
    # Throws a Version::Error if the version cannot be found
    def pacbio_run_sample_sheet_config
      Pipelines.pacbio.sample_sheet.by_version(smrt_link_version.name)
    end

    def generate_name
      return if name.present?

      update(name: "#{NAME_PREFIX}#{id}")
    end
  end
end
