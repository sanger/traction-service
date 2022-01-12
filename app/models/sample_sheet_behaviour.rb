# frozen_string_literal: true

# namespace for handling different sample sheet behaviours
module SampleSheetBehaviour
  BEHAVIOURS = {
    default: SampleSheetBehaviour::Default,
    hidden: SampleSheetBehaviour::Hidden,
    untagged: SampleSheetBehaviour::Untagged
  }.freeze

  def self.get(behaviour_name)
    BEHAVIOURS.fetch(behaviour_name.to_sym).new
  end
end
