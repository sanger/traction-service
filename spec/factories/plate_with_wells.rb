FactoryBot.define do
  factory :plate_with_wells, class: Plate do
    transient do
      well_count { 1 }
    end

    after :create do |plate, options|
      options.well_count.times do |i|
        create(:well, position: "A#{i}", plate: plate)
      end
    end
  end
end
