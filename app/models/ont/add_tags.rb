# frozen_string_literal: true

module Ont
  # cheeky little class which will assign tags by column or row
  # plate can be tagged or untagged
  # can be used to reassign tags that are not in the correct order
  # if the order is column then tags will be added A1, B1, C1, D1, E1, F1, G1, H1 ...
  # if the order is row then tags will be added A1, A2, A3, A4, A5, A6, A7, A8, A9 ...
  # They are the only two options
  class AddTags
    include ActiveModel::Model

    attr_accessor :plate, :tag_set, :order

    def self.run!(args)
      new(args).run!
    end

    def run!
      add_tags
    end

    def columns
      (1..12)
    end

    def rows
      ('A'..'H')
    end

    def ordered_tags
      tag_set.tags.order(:group_id)
    end

    def by_column
      columns.each do |column|
        rows.each do |row|
          yield(row, column)
        end
      end
    end

    def by_row
      rows.each do |row|
        columns.each do |column|
          yield(row, column)
        end
      end
    end

    private

    def add_tags
      tag_index = 0
      send("by_#{order}") do |row, column|
        well = plate.wells.find_by(position: "#{row}#{column}")
        material = well.container_materials.first.material
        material.tags.delete_all
        material.tags << ordered_tags[tag_index]
        tag_index += 1
      end
    end
  end
end
