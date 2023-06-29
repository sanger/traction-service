# frozen_string_literal: true

# Concern for filtering records
# currently will filter out records which are marked for destruction
# could be extended to filter out other records
module HasFilters
  extend ActiveSupport::Concern

  # @return [Boolean]
  # records which are marked for destruction should be excluded from the validation
  def exclude_marked_for_destruction
    @exclude_marked_for_destruction ||= options[:exclude_marked_for_destruction] || false
  end

  private

  # @param [ActiveRecord::Base] record
  # @return [Array]
  # filter out records which are marked for destruction
  def filtered(records)
    return records unless exclude_marked_for_destruction

    records.filter { |record| !record.marked_for_destruction? }
  end
end
