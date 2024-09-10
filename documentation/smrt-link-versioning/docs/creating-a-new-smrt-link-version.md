# Creating a new SMRT Link Version

1. Create a new SMRT Link Version in the configuration file [`config/pacbio_smrt_link_versions.yml`](https://github.com/sanger/traction-serice/blob/develop/config/pacbio_smrt_link_versions.yml):

```yaml
versions:
    v10:
      name: v10
      active: false
      default: false
```

2. Create any new SMRT Link options in the same file and attach the option to any versions it is used in:

```yaml
options:
    ccs_analysis_output:
      key: ccs_analysis_output
      label: "CCS Analysis Output"
      default_value: "Yes"
      validations:
        presence: {}
        inclusion:
          in: *yes_no
      data_type: list
      select_options: *select_yes_no
      versions:
        - v10
```

3. If necessary add the select options in the same file:

```yaml
default: &default
  yes_no: &yes_no ["Yes", "No"]
```

4. Create sample sheet configuration in [`config/pacbio/pacbio.yml`](https://github.com/sanger/traction-service/blob/develop/config/pipelines/pacbio.yml):

```yaml
sample_sheet:
  v12_revio: &v12_revio
```

For old style sample sheets you need to complete the following:
- sample_sheet_class - The class that defines how the sample sheet is created
- column_order - The order that the columns will appear in
- fields - a nested structure to define which fields will appear in the sample sheet e.g. run > wells > samples

For new style sample sheets you will only need a sample sheet class which will define which fields will be used and how they are created. 

???+ info

  The new style sample sheets do not follow the convention that changes that are made can be purely configuration.

  We will see how things progress but it would be better to move them back when the next version is available.


5. Add the SMRT Link Version, Options and default attributes.to the ui [`src/config/PacbioRunWellSmrtLinkOptions.json'](https://github.com/sanger/traction-ui/blob/develop/src/config/PacbioRunWellSmrtLinkOptions.json)

```json
  "v11": [
    {
      "name": "movie_time",
      "component": "traction-select",
      "value": "movie_time",
      "label": "Movie time",
      "required": true,
      "default": true,
      "props": {
        "options": [
          {
            "text": "Movie Time",
            "disabled": true
          },
          "10.0",
          "15.0",
          "20.0",
          "24.0",
          "30.0"
        ],
        "dataAttribute": "movie-time"
      }
    },
    ...
  ],
  "defaultAttributes": {
    "movie_time": null,
    "ccs_analysis_output": "Yes",
    "pre_extension_time": 2,
    "loading_target_p1_plus_p2": 0.85,
    "generate_hifi": "On Instrument",
    "binding_kit_box_barcode": null,
    "on_plate_loading_concentration": null,
    "ccs_analysis_output_include_kinetics_information": "Yes",
    "ccs_analysis_output_include_low_quality_reads": "No",
    "demultiplex_barcodes": "On Instrument",
    "include_fivemc_calls_in_cpg_motifs": "Yes",
    "movie_acquisition_time": "24.0",
    "include_base_kinetics": "False",
    "library_concentration": null,
    "polymerase_kit": null,
    "library_type": "Standard"
  }
```

You will only need to add default attributes if it is a new attribute.

???+ info

    The SMRT Link Options in the front end are repeated for usability.

    The ideal would be to have shared configuration for the ui and the service so data does not need to be repeated.

6. Testing

There is no need to test the underlying code that handles SMRT Link versioning. This is already fully covered.

## Unit tests

- If you need to create a new SampleSheet model then this will need to be tested in isolation e.g. [`spec/support/parsers/pacbio_sample_sheet_v1_parser.rb`](https://github.com/sanger/traction-service/blob/develop/spec/support/parsers/pacbio_sample_sheet_v1_parser.rb)

- If you create a new sample sheet or new version then you will need to test it within Pacbio Run [`spec/models/pacbio/run_spec.rb`](https://github.com/sanger/traction-service/blob/develop/spec/models/pacbio/run_spec.rb)

- Pay particular attention to the rake task tests. [`spec/lib/tasks/create_smrt_link_versions.rake_spec.rb`] (https://github.com/sanger/traction-service/blob/develop/spec/lib/tasks/create_smrt_link_versions.rake_spec.rb)


???+ info

    If you are modifying an existing SMRT Link Version you may well need to change the records manually e.g. if changing an existing validation or name change. The rake task will only create new versions or options.

## Testing locally

- Run the rake task and then start up the ui and service, create a run and download a sample sheet.

## Testing on UAT

- Run the rake task and then create a run and download a sample sheet. You can test this by uploading to the UAT SMRT Link. []()

