# frozen_string_literal: true

# CSVGenerator
class CSVGenerator
  include ActiveModel::Model

  # run           => Pacbio::Run
  # configuration => Pipelines::Configuration::Item
  attr_accessor :run, :configuration

  # return a CSV file
  # using run and configuration attributes
  # to generate headers and data
  def generate_sample_sheet
    file = nil
    # wb => write binary
    CSV.open('sample_sheet.csv', 'wb') do |csv|
      csv << csv_headers

      # assuming each well has one library; this may change in the future
      run.plate.wells.map do |well|
        # new row per well i.e sample
        csv << csv_data(well)
      end

      file = csv
    end
    file
  end

  private

  # return a list of column names ie headers
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.columns.map(&:first)
  end

  # Use configuration :type and :value to retrieve well data
  # eg ["Sequel II", "run4"]
  def csv_data(well)
    configuration.columns.map do |x|
      instance_value(well, x[1])
    end
  end

  def instance_value(obj, field)
    case field[:type]
    when :string
      field[:value]
    when :model
      evaluate_method_chain(obj, field[:value].split('.'))
    when :constant
      evaluate_method_chain(field[:value].split('.').first.constantize,
                            field[:value].split('.')[1..-1])
    end
  end

  def evaluate_method_chain(object, chain)
    chain.inject(object, :send)
  end
end
