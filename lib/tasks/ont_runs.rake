# frozen_string_literal: true

# A set of GraphQL queries for creating ONT plates
module OntPlates
  CreatePlate = TractionGraphQL::Client.parse <<~GRAPHQL
    mutation($barcode: String!, $wells: [WellWithSamplesInput!]!) {
      createPlateWithOntSamples(
        input: {
          arguments: {
            barcode: $barcode
            wells: $wells
          }
        }
      ) { errors }
    }
  GRAPHQL

  # Methods to create variable objects for GraphQL
  class Variables
    def wells(samples_per_well:)
      well_positions = ((1..12).to_a.product %w[A B C D E F G H]).map { |pair| "#{pair[1]}#{pair[0]}" }

      well_positions.map do |position|
        well position: position, num_samples: samples_per_well
      end
    end

    private

    def sample(position:, sample_number:, tag_group_id_prefix:)
      padded_sample_number = format('%<number>03i', { number: sample_number })

      sample = {
        'name' => "Sample #{padded_sample_number} for #{position}",
        'externalId' => "#{position}-#{padded_sample_number}-ExtId"
      }

      unless tag_group_id_prefix.nil?
        padded_tag_number = format('%<number>02i', { number: sample_number })
        sample['tagGroupId'] = "#{tag_group_id_prefix}#{padded_tag_number}"
      end

      sample
    end

    def well(position:, num_samples:)
      {
        'position' => position,
        'samples' => (1..num_samples).map do |number|
          sample(
            position: position,
            sample_number: number,
            tag_group_id_prefix: num_samples == 96 ? 'ont_96_tag_' : nil
          )
        end
      }
    end
  end
end

namespace :ont_runs do
  def show_errors(error_lines)
    error_lines.each { |line| puts line }
    exit
  end

  def submit_create_plate_query(description:, barcode:, wells:)
    puts "-> Creating a plate for #{description}"
    result = TractionGraphQL::Client.query(OntPlates::CreatePlate, variables: { barcode: barcode, wells: wells })

    errors_array = result.original_hash['data']['createPlateWithOntSamples']['errors']
    if errors_array.any?
      show_errors ["-> Failed to create plate for #{description}: #{errors_array}"]
    end

    puts "-> Succesfully created a plate for #{description}"
  rescue Errno::ECONNREFUSED
    show_errors ["-> Failed to connect to the Rails server at #{TractionGraphQL::RAILS_ROOT_URI}",
                 '   Use the RAILS_ROOT_URI environment variable to specify a different URI']
  end

  task create: :environment do
    puts '-> Creating ONT runs using GraphQL'
    puts '   Note these could take a few minutes to complete'
    variables = OntPlates::Variables.new
    submit_create_plate_query(description: 'pooling scenario 1', barcode: 'PLATE-PS01', wells: variables.wells(samples_per_well: 1))
    submit_create_plate_query(description: 'pooling scenario 2', barcode: 'PLATE-PS02', wells: variables.wells(samples_per_well: 1))
    submit_create_plate_query(description: 'pooling scenario 3', barcode: 'PLATE-PS03', wells: variables.wells(samples_per_well: 96))
    puts '-> Successfully created all ONT runs'
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Ont::Request'
    end
    [Ont::Request].each(&:delete_all)
    puts '-> ONT runs successfully deleted'
  end
end
