# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    NAME_PREFIX = 'TRACTION-RUN-'

    include Uuidable
    include Stateful
    include SampleSheet::Run

    # Sequel II and Sequel I are now deprecated
    enum :system_name, { 'Sequel II' => 0, 'Sequel I' => 1, 'Sequel IIe' => 2, 'Revio' => 3 }

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

    # Uses the configuration provided in `config/pacbio_instrument_types.yml`
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

    # combines the library concentration or on plate loading concentration
    # with the tube barcode to generate a comment
    # for each well in the run
    # @example
    #   TRAC-2-10850 304pM  TRAC-2-10851 273pM  TRAC-2-10852 301pM  TRAC-2-10853 315pM
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

    # Collects and returns a list of aliquots to be published during a run.
    # # It iterates over all plates associated with the run, and for each plate, it collects
    # the used aliquots from the wells. It also collects the used aliquots from the wells
    # that have a source type of 'Pacbio::Pool' and further collects the used aliquots
    # from these pools that have a source type of 'Pacbio::Library'.
    # @return [Array] An array of aliquots that are either sourced from Pacbio::Pool,Pacbio::Library
    # and aliquots that have a source of 'Pacbio::Library' within those pools.
    def aliquots_to_publish_on_run
      to_publish = []
      plates.flat_map do |plate|
        # Collect all used aliquots from the plate
        used_aliquots = plate.wells.flat_map(&:used_aliquots)
        # Collect all used aliquots from the plate that have a source of 'Pacbio::Pool'
        used_aliquots_pool_source = used_aliquots
                                    .select { |aliquot| aliquot.source_type == 'Pacbio::Pool' }
        # Aggregate all used aliquots from the plate and used aliquots from the pool with
        # a source of 'Pacbio::Library'
        to_publish.concat(used_aliquots,
                          used_aliquots_lib_source_in_pool(used_aliquots_pool_source))
      end
      to_publish
    end

    # This method filters and retrieves all aliquots from a given collection of pools
    # where the aliquot's source is of type 'Pacbio::Library'.
    #
    # @param pools [Array] An array of pools
    # @return [Array] An array of aliquots that have a source of type 'Pacbio::Library'.
    def used_aliquots_lib_source_in_pool(pools)
      pools.flat_map(&:source).flat_map(&:used_aliquots)
           .select do |aliquot|
        aliquot.source_type == 'Pacbio::Library'
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
