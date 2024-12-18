# frozen_string_literal: true

module RunCsv
  # RunCsv::OntSampleSheet
  # Used to generate sample sheets specific to the ONT pipeline
  # For usage documentation see 'app/exchanges/README.md'
  class OntSampleSheet
    include DataStructureBuilder

    # return a CSV String
    # using run and configuration attributes
    # to generate headers and data
    def generate
      run = object
      CSV.generate do |csv|
        csv << csv_headers

        run.flowcells.each do |flowcell|
          csv_sample_rows(flowcell).each { |sample_row| csv << sample_row }
        end
      end
    end

    private

    # return a list of column names ie headers
    # eg ['flow_cell_id', 'sample_id']
    def csv_headers
      configuration.columns.map(&:first)
    end

    def csv_sample_rows(flowcell)
      flowcell.pool.libraries.map do |library|
        csv_data(sample: library, flowcell:, row_type: :sample)
      end
    end

    # Use configuration :type and :value to retrieve flowcell data
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
    # populate[:for] is either sample or flowcell
    # populate[:with] is either row_type (sample or flowcell), sample or flowcell
    # For usage documentation see 'app/exchanges/README.md'
    # @param [hash] options can include:
    #  - flowcell: the flowcell data that is being added to the row
    #  - sample: the sample data that is being added to the row
    #  - column_options: from configuration
    def populate_column(options = { flowcell: nil, sample: nil, column_options: nil })
      populate = options[:column_options][:populate]
      return '' unless populate[:for].include?(options[:row_type])

      obj = populate[:with] == :row_type ? options[options[:row_type]] : options[populate[:with]]
      instance_value(obj, options[:column_options])
    end
  end
end
