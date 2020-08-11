# frozen_string_literal: true

# CSVGenerator
class CsvGenerator
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
        csv << csv_data(well: well, row_type: :well)

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
      csv_data(sample: request_library, well: well, row_type: :sample)
    end
  end

  # Use configuration :type and :value to retrieve well data
  # eg ["Sequel II", "run4"]
  def csv_data(options = {})
    configuration.columns.map do |column|
      populate_column(options.merge(column_options: column[1]))
    end
  end

  # if the column does not need to be populated for the row_type return empty string
  # if the column does need to be populated then return the value from the object
  # populating on row_type means that we need to populate it with the object
  # pertaining to the row type
  # otherwise just populate with the populate with value.
  # some columns need populating for both types with the same method (polymorphism).
  # well position is different. It would be really difficult to get that from sample.
  # populate[:for] is either sample or well
  # populate[:with] is either row_type (sample or well), sample or well
  # Examples:
  # +Is Collection:
  # type: :model
  # value: collection?
  # populate:
  #   for:
  #     - :well
  #     - :sample
  #   with: :row_type+
  # means that is collection needs to be populated for samples and wells
  # but needs to use the method from sample or well as the answers are different
  # +Sample Well:
  # type: :model
  # value: position_leading_zero
  # populate:
  #   for:
  #     - :well
  #     - :sample
  #   with: :well+
  # means that sample well needs to be populated for both samples and wells
  # but needs to use the well method
  # hopefully that is enough of an explanation!
  def populate_column(options = {})
    populate = options[:column_options][:populate]
    return '' unless populate[:for].include?(options[:row_type])

    obj = populate[:with] == :row_type ? options[options[:row_type]] : options[populate[:with]]
    instance_value(obj, options[:column_options])
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
