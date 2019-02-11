# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Adding enzymes to the database
unless Rails.env.test?
  ["Nb.BbvCI", "Nb.BsmI", "Nb.BsrDI", "Nt.BspQI", "Nb.BssSI", "DLE-1"].each do |enzyme_name|
      Enzyme.create(name: enzyme_name)
  end
end
