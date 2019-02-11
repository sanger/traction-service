# frozen_string_literal: true

# LibraryFactory
class LibraryFactory
  include ActiveModel::Model

  validate :check_libraries

  def initialize(attributes = [])
    attributes.each { |library| libraries << Library.new(library.merge!(tube: Tube.new)) }
  end

  def libraries
    @libraries ||= []
  end

  def save
    return false unless valid?

    libraries.collect(&:save)
    true
  end

  private

  def check_libraries

    if libraries.empty?
      errors.add('libraries', 'the were no libraries')
      return
    end

    libraries.each do |library|
      next if library.valid?

      library.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
