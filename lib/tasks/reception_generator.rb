# frozen_string_literal: true

require 'factory_bot'

# Used to generate test data for a given pipeline
class ReceptionGenerator
  def initialize(number_of_plates:, number_of_tubes:, wells_per_plate:, pipeline:)
    @number_of_plates = number_of_plates
    @number_of_tubes = number_of_tubes
    @wells_per_plate = wells_per_plate
    @pipeline = pipeline
    @timestamp = Time.now.to_i
    @library_types = LibraryType.where(pipeline: @pipeline).pluck(:name).cycle
    @data_types = DataType.where(pipeline: @pipeline).pluck(:name).cycle
    @sample_names = (1..).lazy.map { |id| "GENSAMPLE-#{@timestamp}-#{id}" }
    @barcodes = (1..).lazy.map { |bc| "GEN-#{@timestamp}-#{bc}" }
    @well_positions = (1..12).flat_map { |r| ('A'..'H').map { |c| "#{c}#{r}" } }
  end

  def construct_resources!
    # Ensure we've loaded our factories.
    FactoryBot.reload if FactoryBot.factories.count == 0
    reception.construct_resources!
  end

  def reception
    @reception ||= Reception.create!(
      source: 'traction-service.rake-task',
      plates_attributes: [
        *plates,
      ],
      tubes_attributes: [
        *tubes,
      ]
    )
  end

  private

  # Rubocop wants us to use .empty instead of size > 0
  # But enumerators don't have a .empty method
  # rubocop:disable Style/ZeroLengthPredicate
  def plates
    @number_of_plates.times.flat_map do
      barcode = @barcodes.next
      library_type = @library_types.next
      data_type = @data_types.next if @data_types.size > 0
      wells_attributes = @well_positions.take(@wells_per_plate).map do |position|
        {
          position:,
          request: request(library_type, data_type),
          sample:,
        }
      end
      {
        barcode:,
        wells_attributes:
      }
    end
  end

  def request(library_type, data_type)
    FactoryBot.attributes_for(:"#{@pipeline}_request").merge(library_type:, data_type:).compact
  end

  def sample
    FactoryBot.attributes_for(:sample, name: @sample_names.next)
  end

  def tubes
    @number_of_tubes.times.map do
      barcode = @barcodes.next
      library_type = @library_types.next
      data_type = @data_types.next if @data_types.size > 0
      {
        barcode:,
        request: request(library_type, data_type),
        sample:
      }
    end
  end
  # rubocop:enable Style/ZeroLengthPredicate
end
