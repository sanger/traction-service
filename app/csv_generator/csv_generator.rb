# frozen_string_literal: true

# CSVGenerator
class CSVGenerator
  include ActiveModel::Model

  attr_accessor :run, :configuration

  # return a CSV file
  # using run and configuration attributes
  # to generate headers and data
  def generate_sample_sheet
    file = nil
    CSV.open('file.csv', 'wb') do |csv|
      csv << csv_headers

      run.plate.wells.map do |well|
        csv << csv_data(well)
      end

      file = csv
    end
    file
  end

  private

  # return a list of column names
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.columns.map do |x|
      x[0]
    end
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
