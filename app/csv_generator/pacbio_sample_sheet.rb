# frozen_string_literal: true

# PacbioSampleSheet
# Used to generate sample sheets specific to the Pacbio pipeline
# For usage documentation see 'app/csv_generator/README.md'
class PacbioSampleSheet
  include ActiveModel::Model

  # run           => Pacbio::Run
  # configuration => Pipelines::Configuration::Item
  attr_accessor :run, :configuration

  # return a CSV String
  # using run and configuration attributes
  # to generate headers and data
  def generate
    CSV.generate do |csv|
      csv << csv_headers

      sorted_wells.each do |well|
        # add well header row
        csv << csv_data(well:, row_type: :well)

        next unless well.show_row_per_sample?

        csv_sample_rows(well).each { |sample_row| csv << sample_row }
      end
    end
  end

  private

  def wells
    run.plates.flat_map(&:wells)
  end

  # Returns a list of wells associated with the plate in column order
  # Example: [<Well position:'A1'>, <Well position:'A2'>, <Well position:'B1'>]) =>
  #          [<Well position:'A1'>, <Well position:'B1'>, <Well position:'A2'>]
  def sorted_wells
    wells.sort_by { |well| [well.column.to_i, well.row] }
  end

  # return a list of column names ie headers
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.columns.map(&:first)
  end

  def csv_sample_rows(well)
    well.libraries.map do |library|
      # add row under well header for each sample in the well
      csv_data(sample: library, well:, row_type: :sample)
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
  # For usage documentation see 'app/csv_generator/README.md'
  # @param [hash] options can include:
  #  - well: the well data that is being added to the row
  #  - sample: the sample data that is being added to the row
  #  - column_options: from configuration
  def populate_column(options = { well: nil, sample: nil, column_options: nil })
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
      const_obj, *methods = field[:value].split('.')
      evaluate_method_chain(const_obj.constantize, methods)
    end
  end

  def evaluate_method_chain(object, chain)
    chain.inject(object, :send)
  end
end
