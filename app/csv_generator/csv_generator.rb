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

      run.plate.wells.each do |well|
        # add well header row
        csv << csv_data(well, true, well.sample_names)

        next unless well.all_libraries_tagged

        csv_sample_rows(well).each { |sample_row| csv << sample_row }
      end
    end
  end

  private

  # return a list of column names ie headers
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.columns.map(&:first)
  end

  def csv_sample_rows(well)
    well.request_libraries.map do |request_library|
      # add row under well header for each sample in the well
      csv_data(request_library, false, well.sample_names)
    end
  end

  # Use configuration :type and :value to retrieve well data
  # eg ["Sequel II", "run4"]
  def csv_data(obj, is_well_header_row, sample_names)
    configuration.columns.map do |x|
      column_name = x[0]
      column_options = x[1]

      next is_well_header_row if column_name == 'Is Collection'
      next sample_names if column_name == 'Sample Name'

      if should_populate_column(column_options[:populate_on_row_type], is_well_header_row)
        instance_value(obj, column_options)
      else
        ''
      end
    end
  end

  def should_populate_column(populate_on_row_type, is_well_header_row)
    populate_on_row_type == :all ||
      populate_on_row_type == :well && is_well_header_row ||
      populate_on_row_type == :sample && !is_well_header_row
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
