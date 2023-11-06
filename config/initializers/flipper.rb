# frozen_string_literal: true

require 'yaml'

FLIPPER_FEATURES = YAML.load_file('./config/feature_flags.yml')

Flipper::UI.configure do |config|
  config.descriptions_source = ->(_keys) { FLIPPER_FEATURES }
  config.banner_text = "#{Rails.application.engine_name} [#{Rails.env}]"
  config.banner_class = Rails.env.production? ? 'danger' : 'info'

  # If there aren't any flags in the list, flipper will render the Taylor Swift
  # video 'Blank Space'. Unfortunately the permissions on my browser at least
  # meant that this didn't work, and it wasn't entirely clear that it wasn't
  # hiding anything important. So sadly, I have to disable the feature.
  # But as I have nothing against TayTay:
  # https://www.youtube.com/watch?v=e-ORhEE9VVg
  config.fun = false

  # Defaults to false. Set to true to show feature descriptions on the list
  # page as well as the view page.
  config.show_feature_description_in_list = true
end

begin
  # Automatically add tracking of features in the yaml file
  FLIPPER_FEATURES.each_key { |feature| Flipper.add(feature) }
rescue ActiveRecord::ActiveRecordError => e
  Rails.logger.warn(e.message)
  Rails.logger.warn('Features not registered with flipper')
end

# rubocop has got this very wrong. It removes the literal and breaks everything
# TODO: once feature flags are removed move this back to the config/application.rb
# rubocop:disable Layout/LineLength
# Rails.configuration.pacbio_instrument_types = if Flipper.enabled?(:dpl947_enable_dna_control_barcode_pacbio_sequel_ii_v12)
#                                                 Rails.application
#                                                      .config_for(:pacbio_instrument_types_v2)
#                                               else
#                                                 Rails.application
#                                                      .config_for(:pacbio_instrument_types_v1)
#                                               end
# rubocop:enable Layout/LineLength
