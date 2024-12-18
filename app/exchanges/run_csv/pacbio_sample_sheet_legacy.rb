# frozen_string_literal: true

module RunCsv
  # RunCsv::PacbioSampleSheet
  # Used to generate sample sheets specific to the PacBio pipeline for v12 and above
  class PacbioSampleSheetLegacy
    include DataStructureBuilder

    # return a list of column names ie headers
    # eg ['System Name', 'Run Name']
    def csv_headers
      configuration.column_order
    end

    # Returns true if the object can be iterated using `each`,
    # false otherwise
    def eachable?(object)
      object.respond_to?(:each)
    end

    # Flattens a nested hash of arrays into a 1D array.
    # Includes non-iterable key-value pairs in the result.
    def recursive_array_extractor(array_of_hashes)
      rows = []
      array_of_hashes.each do |hash_element|
        rows << hash_element
        hash_element.values.each do |values|
          if eachable? values
            child_rows = recursive_array_extractor(values)
            rows.push(*child_rows)
          end
        end
      end
      rows
    end

    # Parse the JSON data structure to derive the CSV. If a
    # value contains an array, the key name will be ignored
    # and the individual array elements parsed.
    def payload
      CSV.generate do |csv|
        csv << csv_headers
        generate_csv_rows(csv)
      end
    end

    def generate_csv_rows(csv)
      data_rows = recursive_array_extractor([data_structure])
      # Initialize a flag to track if this is the first row
      first_row = true

      data_rows.each do |row|
        row_values = process_row(row, first_row)
        first_row = false if first_row && !row_values.all?(nil)
        csv << row_values unless row_values.all?(nil)
      end
    end

    def process_row(row, first_row)
      row_values = row.values_at(*csv_headers)
      handle_csv_version(row_values, first_row)
      row_values
    end

    def handle_csv_version(row_values, first_row)
      # CSV VERSION should be set only on first row
      return if first_row

      index = csv_headers.index('CSV Version')
      row_values[index] = nil if index
    end
  end
end
