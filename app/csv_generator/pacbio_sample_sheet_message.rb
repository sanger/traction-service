# frozen_string_literal: true

# Creates a message in the correct structure for the warehouse
class PacbioSampleSheetMessage < DataStructureBuilder
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

      data_rows = recursive_array_extractor([data_structure])
      data_rows.each do |row|
        row_values = row.values_at(*csv_headers)
        csv << row_values unless row_values.all?(nil)
      end
    end
  end
end
