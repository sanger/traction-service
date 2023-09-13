# frozen_string_literal: true

module RunCsv
  # RunCsv::DeprecatedPacbioSampleSheet
  # Used to generate sample sheets specific to the Pacbio pipeline for v10 & v11
  # For usage documentation see 'app/exchanges/README.md'
  class DeprecatedPacbioSampleSheet < DataStructureBuilder
    # return a CSV String
    # using run and configuration attributes
    # to generate headers and data
    def payload
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

    # Returns a list of wells associated with the plate in column order
    # Example: [<Well position:'A1'>, <Well position:'A2'>, <Well position:'B1'>]) =>
    #          [<Well position:'A1'>, <Well position:'B1'>, <Well position:'A2'>]
    #
    # **DEPRECATED:** replaced by SampleSheet::Run#sorted_wells
    def sorted_wells
      run = object
      run.wells.sort_by { |well| [well.column.to_i, well.row] }
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
    # For usage documentation see 'app/exchanges/README.md'
    # @param [hash] options can include:
    #  - well: the well data that is being added to the row
    #  - sample: the sample data that is being added to the row
    #  - column_options: from configuration
    def populate_column(options = { well: nil, sample: nil, column_options: nil })
      populate = options[:column_options][:populate]
      return nil unless populate[:for].include?(options[:row_type])

      obj = populate[:with] == :row_type ? options[options[:row_type]] : options[populate[:with]]
      instance_value(obj, options[:column_options], :column)
    end
  end
end
