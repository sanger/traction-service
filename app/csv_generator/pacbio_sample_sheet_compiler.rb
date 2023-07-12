# frozen_string_literal: true

# Generate sample sheets for different versions
# This is an "abstract" base class that should be inherited to define the COLUMN_CONFIG for each
# required sample sheet version.
# See `PacbioSampleSheetV12Revio` for a prescriptive use case.
class PacbioSampleSheetCompiler
  COLUMN_CONFIG = {}.freeze

  def initialize(run)
    @run = run
  end

  # Returns a flattened array of wells from the multiple plates within a run
  def wells
    @run.plates.flat_map(&:wells)
  end

  # Returns a list of wells associated with the plate in column order
  # Example: [<Well position:'A1'>, <Well position:'A2'>, <Well position:'B1'>]) =>
  #          [<Well position:'A1'>, <Well position:'B1'>, <Well position:'A2'>]
  def sorted_wells
    wells.sort_by { |well| [well.column.to_i, well.row] }
  end

  def csv_sample_rows(well)
    well.libraries.map do |library|
      # add row under well header for each sample in the well
      csv_data(sample: library, well:, row_type: :sample)
    end
  end

  def generate_headers
    self.class::COLUMN_CONFIG.keys.map(&:to_s) # convert the symbols (from freezing) to strings
  end

  # Given the context arguments and the column lambda, evaluate the lambda and return the result.
  # `args` is a hash, as defined for use in column-config above
  def evaluate_column(args, column_lambda)
    column_lambda.call(args) || '' # convert nils to empty strings
  end

  # Return an Array of values in a row for the given args
  def generate_row(args)
    self.class::COLUMN_CONFIG.values.map { |column_lambda| evaluate_column(args, column_lambda) }
  end

  def generate
    CSV.generate do |csv|
      csv_headers = generate_headers

      csv << csv_headers

      sorted_wells.each do |_well|
        row = self.class::COLUMN_CONFIG.values.map { |value| value.call(c) }

        # next unless well.show_row_per_sample?

        # csv_sample_rows(well).each { |sample_row| csv << sample_row }
      end
    end
  end
end
