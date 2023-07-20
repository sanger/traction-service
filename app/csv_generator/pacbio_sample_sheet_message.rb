# frozen_string_literal: true

# Creates a message in the correct structure for the warehouse
class PacbioSampleSheetMessage
  include ActiveModel::Model

  attr_accessor :object, :configuration

  # Produces the message in the correct format
  # Example:
  #   {"lims"=>"Traction", "bmap_flowcell"=>{"sample_uuid"=>"5",
  #     "study_uuid"=>"5", "experiment_name"=>5, "enzyme_name"=>"Nb.BssSI",
  #     "chip_barcode"=>"FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX",
  #     "chip_serialnumber"=>"FLEVEAOLPTOWPNWU", "position"=>2, "id_library_lims"=>5,
  #     "id_flowcell_lims"=>10, "instrument_name"=>"saphyr",
  #     "last_updated"=>Mon, 12 Aug 2019 12:37:51 UTC +00:00}}
  def content
    configuration.fields.each_with_object({}) do |(k, v), r|
      r[k] = instance_value(object, v, :root)
    end
  end

  # Content as json
  def payload
    content.to_json
  end

  # return a list of column names ie headers
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.column_order
  end

  # Content as csv
  def payload_csv
    # puts content

    csv = CSV.generate do |csv|
      csv << csv_headers
      # content = {"sorted_wells"=>[{"Library Type"=>"Standard",
      content.values.each do |children|
        # children = [{"Library Type"=>"Standard",
        children.each do |child|
          csv << child.values_at(*csv_headers)
          # child = {"Library Type"=>"Standard",...,"samples"=>[{"Reagent Plate"=>1,

          child.values.select { |v| v.respond_to?(:each) }.each do |grandchildren|
            # grandchildren = [{"Reagent Plate"=>1,
            grandchildren.each do |grandchild|
              # grandchild = {"Reagent Plate"=>1,

              row_data = grandchild.values_at(*csv_headers)
              row_data = row_data.map { |col| col || '' } # replace nil with empty string
              csv << row_data
            end
          end
        end
      end
    end
  end

  # If the message contains a number of children for example
  # with Pacbio each well will have a number of samples
  # For each field get the value
  # This is applied to the nested object not the
  # original object
  def build_children(object, field)
    Array(object.send(field[:value])).collect do |o|
      field[:children].each_with_object({}) do |(k, v), r|
        r[k] = instance_value(o, v, object)
      end
    end
  end

  # Find the instance value for each field
  # If the field is a:
  # * [string]    - return the value
  # * [model]     - take the value split it by the full stop
  #                 and recursively send the method to the object
  #                 e.g. it is object.foo.bar will first evaluate
  #                 foo and then apply bar
  # * [parent_model] - as above, but applied to the parent object
  # * [constant]  - Takes the constant and applies the method chain
  #                 to it e.g DateTime.now
  # * [array]     - usually an array of fields
  def instance_value(object, field, parent)
    case field[:type]
    when :string
      field[:value]
    when :model
      evaluate_method_chain(object, field[:value].split('.'))
    when :parent_model
      evaluate_method_chain(parent, field[:value].split('.'))
    when :constant
      evaluate_method_chain(field[:value].split('.').first.constantize,
                            field[:value].split('.')[1..])
    when :array
      build_children(object, field)
    end
  end

  # we need to do this via try as certain fields may be nil
  def evaluate_method_chain(object, chain)
    chain.inject(object) { |o, meth| o.try(:send, meth) }
  end
end

# ==================================== CSV BELOW ==================================== #

# PacbioSampleSheet
# Used to generate sample sheets specific to the Pacbio pipeline
# For usage documentation see 'app/csv_generator/README.md'
class PacbioSampleSheetMessageCSV
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
