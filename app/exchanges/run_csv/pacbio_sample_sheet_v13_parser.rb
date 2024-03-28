# frozen_string_literal: true

module RunCsv
  # RunCsv::PacbioSampleSheetV13Parser
  class PacbioSampleSheetV13Parser
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

      run_settings = {}
      section_content.split("\n").each do |line|
        key, value = line.split(',')
        run_settings[key] = value
      end

      run_settings
    end

    def parse_smrt_cell_settings(section_content)
      # SMRT Cell Settings
      # the content should be in the form of a hash of hashes, one for each SMRT cell
      # the hash should contain key-value pairs for each SMRT cell setting, zipped from the row data
      #
      # Input:
      # ,1_A01,1_B01,2_A01
      # Well Name,Sample1_CCS,Sample2_CCS_BC,Sample3_CCS_basic
      # Well Comment,Sample 1 comment,Sample 2 comment,Sample 3 comment
      # Application,HiFi Reads,HiFi Reads,Unspecified
      # Library Type,Standard,Standard,Standard
      # Movie Acquisition Time (hours),24,24,24
      #
      # Output:
      # expect(parsed_sample_sheet['SMRT Cell Settings']).to eq(
      #   {
      #     '1_A01' => {
      #       'Well Name' => 'Sample1_CCS',
      #       'Well Comment' => 'Sample 1 comment',
      #       'Application' => 'HiFi Reads',
      #       'Library Type' => 'Standard',
      #       'Movie Acquisition Time (hours)' => '24',
      #       'Insert Size (bp)' => '2000',
      #       'Assign Data To Project' => '1',
      #       'Library Concentration (pM)' => '7',
      #       'Include Base Kinetics' => 'FALSE'
      #     },
      #     '1_B01' => {

      smrt_cell_settings = {}
      lines = section_content.split("\n")
      well_indentifiers = lines[0].split(',')[1..]

      lines[1..].each do |line|
        key, *values = line.split(',')
        values.each_with_index do |value, index|
          well_indentifier = well_indentifiers[index]
          smrt_cell_settings[well_indentifier] ||= {}
          smrt_cell_settings[well_indentifier][key] = value
        end
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
    def parse_sample_sheet(sample_sheet_string)
      sections = split_into_sections(sample_sheet_string)

      run_settings = parse_run_settings(sections['Run Settings'])
      smrt_cell_settings = parse_smrt_cell_settings(sections['SMRT Cell Settings'])
      sample_settings = parse_sample_settings(sections['Samples'])

      {
        'Run Settings' => run_settings,
        'SMRT Cell Settings' => smrt_cell_settings,
        'Samples' => sample_settings
      }
    end
  end
end
