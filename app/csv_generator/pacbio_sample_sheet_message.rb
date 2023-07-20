# frozen_string_literal: true

# Creates a message in the correct structure for the warehouse
class PacbioSampleSheetMessage < DataStructureBuilder
  # return a list of column names ie headers
  # eg ['System Name', 'Run Name']
  def csv_headers
    configuration.column_order
  end

  # Data Structure as csv
  def payload
    CSV.generate do |csv|
      csv << csv_headers
      # data_structure = {"sorted_wells"=>[{"Library Type"=>"Standard",
      data_structure.values.each do |children|
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
end
