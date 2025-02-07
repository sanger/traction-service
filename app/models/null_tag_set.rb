# frozen_string_literal: true

# NullTagSet
# Represents a null tag set where one does not exist
# This is used to avoid nil checks in the code
# used for sample sheet behaviour
class NullTagSet
  # return [Boolean] false
  def default_sample_sheet_behaviour?
    false
  end

  # return [Boolean] false
  def hidden_sample_sheet_behaviour?
    false
  end

  # return nil
  def uuid; end
end
