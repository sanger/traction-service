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
              csv << grandchild.values_at(*csv_headers)
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

private

# Returns a list of wells associated with the plate in column order
# Example: [<Well position:'A1'>, <Well position:'A2'>, <Well position:'B1'>]) =>
#          [<Well position:'A1'>, <Well position:'B1'>, <Well position:'A2'>]
def sorted_wells
  wells.sort_by { |well| [well.column.to_i, well.row] }
end
