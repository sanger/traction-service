# frozen_string_literal: true

module Version
  # I have gone for the simple option. We could go full semver but that would be complicated
  # and unnecessary
  # using a full stop would break method naming so I have gone for underscore
  # having the format here gives us the advantage of modifying easily.
  FORMAT = /\Av\d{2}?_?\d{1,2}\z/
end
