# frozen_string_literal: true

# Although this strictly relates to SMRT Link it makes sense to leave it as generic
# Due to the way we are using it. Always possible to specialise later
module Version
  # I have gone for the simple option. We could go full semver but that would be complicated
  # and unnecessary
  # using a full stop would break method naming so I have gone for underscore
  # having the format here gives us the advantage of modifying easily.
  FORMAT = /v\d[a-z0-9_]*\z/

  # Bespoke error class to highlight version errors
  class Error < StandardError
    def message
      'Unsupported or invalid version'
    end
  end
end
