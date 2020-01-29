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
    CSV.generate do |csv|
      csv << csv_headers

      # assuming each well has one library; this may change in the future
      run.plate.wells.map do |well|
        # new row per well
        csv << csv_data(well, true)

        # if well has multiple libraries, add more rows for them here
        well.libraries.map do |library|
          library.request_libraries.map do |request_library|
            csv << csv_data(request_library, false)
          end
        end
      end
    end
  end

  private

  # return a list of column names ie headers
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.columns.map(&:first)
  end

  # Use configuration :type and :value to retrieve well data
  # eg ["Sequel II", "run4"]
  def csv_data(obj, is_well_header_row)
    configuration.columns.map do |x|
      column_options = x[1]
      should_populate_column = ((is_well_header_row && column_options[:row_type] == :well) ||
                                (!is_well_header_row && column_options[:row_type] == :sample))

      if x[0] == 'Is Collection'
        is_well_header_row
      elsif should_populate_column
        instance_value(obj, column_options)
      else
        ''
      end
    end
  end

  # TODO: refactor duplication with messages/message.rb
  # Find the instance value for each field
  # If the field is a:
  # * [string]    - return the value
  # * [model]     - take the value split it by the full stop
  #                 and recursively send the method to the object
  #                 e.g. it is object.foo.bar will first evaluate
  #                 foo and then apply bar
  # * [constant]  - Takes the constant and applies the method chain
  #                 to it e.g DateTime.now
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
