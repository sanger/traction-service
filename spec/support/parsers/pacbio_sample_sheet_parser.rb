# frozen_string_literal: true

module Parsers
  # Parsers::PacbioSampleSheetParser
  # Use to parse PacBio sample sheets of Revio (introduced in SMRT Link v13)
  # Example usage:
  #    parsed_sample_sheet = Parsers::PacbioSampleSheetParser.new.parse(sample_sheet_string)
  class PacbioSampleSheetParser
    # these keys (columns) are excluded because they break value-per-well mapping and
    # aren't used in our implementation
    EXCLUDE_KEYS = ['Pipeline Id', 'Analysis Name', 'Entry Points', 'Task Options'].freeze

    def split_into_sections(sample_sheet_string)
      # returns an hash of sections and their contents as strings
      # {
      #   'Run Settings' => 'content',
      #   'SMRT Cell Settings' => 'content',
      #   'Samples' => 'content'
      # }
      sections = {}

      sample_sheet_string.split(/(?>^|\n)\[/).each do |section|
        next if section.empty?

        section_name = section.match(/(.*)\]/)[1]
        section_content = section.gsub(/.*\]/, '').strip
        sections[section_name] = section_content
      end

      sections
    end

    def parse_run_settings(section_content)
      # returns a hash of key-value pairs
      # split on newlines, then split on commas
      {}.tap do |run_settings|
        section_content.split("\n").each do |line|
          key, value = line.split(',', -1)
          run_settings[key] = value
        end
      end
    end

    def process_values_into_smrt_cell_settings(settings, key, values)
      plate_wells = settings.keys

      # check that the number of values matches the number of well identifiers
      if values.length != plate_wells.length
        raise "Invalid number of values for key '#{key}', " \
              "expected #{plate_wells.length}, got #{values.length}"
      end

      values.each_with_index do |value, index|
        plate_well = plate_wells[index] # get the plate well from [1_A01, 1_B01, ...]

        # Check the value types and convert them as appropriate
        # value looks like boolean (case insensitive)
        value = evaluates_as_true?(value) if value =~ /\A(true|false)\z/i

        settings[plate_well][key] = value # assign the value to the plate well in the hash
      end
    end

    # Parses SMRT cell settings from a given section content.
    #
    # @param section_content [String] The section content to parse.
    # @return [Hash] A hash mapping well identifiers to their settings.
    #
    # @example
    #   parse_smrt_cell_settings("A1,A2,A3\nKey1,Value1,Value2,Value3")
    #   {"A1" => {"Key1" => "Value1"}, "A2" => {"Key1" => "Value2"}, "A3" => {"Key1" => "Value3"}}
    def parse_smrt_cell_settings(section_content)
      lines = section_content.split("\n")
      plate_wells = lines[0].split(',', -1)[1..]

      # create an empty hash for each plate well
      smrt_cell_settings = plate_wells.index_with { |_plate_well| {} }

      lines[1..].each do |line|
        key, *values = line.split(',', -1)

        # skip excluded keys
        next if EXCLUDE_KEYS.include?(key)

        process_values_into_smrt_cell_settings(smrt_cell_settings, key, values)
      end

      smrt_cell_settings
    end

    def parse_sample_settings(section_content)
      # Parses the sample settings section of the sample sheet, returning an array of hashes
      CSV.parse(section_content, headers: true).map(&:to_h)
    end

    # Parses the sample sheet into sections for easier testing
    # Returns hashes of the sections and their contents
    #
    # @param [String] sample_sheet_string
    # @return [Hash]
    def parse(sample_sheet_string)
      sections = split_into_sections(sample_sheet_string)
      {
        'Run Settings' => parse_run_settings(sections['Run Settings']),
        'SMRT Cell Settings' => parse_smrt_cell_settings(sections['SMRT Cell Settings']),
        'Samples' => parse_sample_settings(sections['Samples'])
      }
    end

    private

    def evaluates_as_true?(value)
      value.downcase == 'true'
    end
  end
end
