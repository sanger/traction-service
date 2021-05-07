# MockPlates
# a factory which builds a plate in the image of what would be sent from the front end
# will be constructed with rows and columns with each space being a hash of a well
# each well will be either empty or will have a sample (in an array) depending on the 
# number of samples that have been passed
class ExternalPlate

  attr_reader :barcode

  def initialize(attributes)
    @barcode = attributes[:barcode]
    @rows = attributes[:rows]
    @columns = attributes[:columns]
    @samples = attributes[:samples]

    build_wells
  end

  def wells
    @wells ||= []
  end

  def to_h
    {
      barcode: barcode,
      wells: wells
    }
  end

  private

  def build_wells
    @rows.each do |row|
      (1..@columns).each do |column|

        well = { position: "#{row}#{column}" }

        # this is easier than constructing our own sample as they will be unique
        # if we pop the sample off each time no need to count
        # if the samples are empty then no need to pop anymore
        # attributes will contain things like id etc so we need to remove anything that is nil
        well[:samples] = [ @samples.pop ] unless @samples.empty?
        wells << well
      end
    end
  end
  
end

FactoryBot.define do
  factory :external_plate, class: ExternalPlate do

    sequence(:barcode) { |n| "DN#{n}" }
    rows { ['A','B','C','D','E','F','G','H'] }
    columns { 12 }
    samples { build_list(:external_sample, 48) }

    initialize_with { new(**attributes).to_h.with_indifferent_access }

    skip_create

  end
end