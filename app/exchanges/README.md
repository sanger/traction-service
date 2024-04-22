# Exchanges Output Generator

The exchanges codebase generates messages and sample sheets for external interfaces.

The messages and sample sheets are defined through configuration in
[/config/pipelines/](/config/pipelines/)`{pipeline}.yml` for ONT and PacBio. The
[DataStructureBuilder](/app/exchanges/data_structure_builder.rb) parses the configuration with
additional functionality added to
[/app/exchanges/run_csv/](/app/exchanges/run_csv/)`{pipeline}_sample_sheet.rb` as required.

The required format of the sample sheets can be found in the SMRT Link User Guides
(https://www.pacb.com/support/documentation/).

Once generated, the sample sheets are uploaded to SMRT Link, a test instance can be found on UAT.

**Note:**

- ONT uses `flowcell` and `sample`
- PacBio uses `well` and `sample`

## Configuration

_As implemented in [data_structure_builder.rb](/app/exchanges/data_structure_builder.rb) and
[pacbio_sample_sheet.rb](/app/exchanges/run_csv/pacbio_sample_sheet.rb)_

The `DataStructureBuilder::data_structure` method parses the configuration for the pipeline and
returns a hash containing the requested data.

### Column Order

The `column_order` key defines the order in which the columns should be displayed in the sample
sheet. The value of each item should match the name of the fields as defined in `fields.children`.

### Fields

Each field is defined with a `type` and a `value`. The `type` defines how the value is populated and
the `value` defines what the value is populated with.

If the field is a:

- **[string]** => return the value as a constant
- **[constant]** => evaluate the first item as a Rails constant and apply the method chain to it,  
  eg: `DateTime.now`
- **[model]** => take the value split it by the full stop and recursively send the method to the
  model object,  
  eg: `object.foo.bar` will first evaluate foo and then apply bar
- **[parent_model]** => as above, but for the direct parent of the current model
- **[array]** => evaluate the value as a method on the object and return an array of the results

Methods that are available for use are defined for `:model` and `:parent_model` in the models
themselves as well as in [/app/models/concerns/sample_sheet.rb](/app/models/concerns/sample_sheet.rb)

Example:

```yaml
v12_revio: # version name
  column_order: # list of columns in the order they should appear in the sample sheet
    - Library Type
    - Reagent Plate
    - Bio Sample Name
  fields: # list of fields to be populated
    _sorted_wells: # a placeholder field for all the rows in the sample sheet
      type: :array # process the value as an array
      value: sorted_wells # call the sorted_wells method in 'app/models/concerns/sample_sheet.rb'
      children: # placeholder field 'containing' the elements from the sorted_wells array (Wells)
        Library Type: # column name
          type: :string # return the value as a string constant
          value: Standard # literally the text 'Standard'
        Reagent Plate: # another column name
          type: :model # this time call a method on the model
          value: plate.plate_number # the method chain should be (well).plate.plate_number
        Bio Sample Name: # yet another column name
          type: :model # call a method on the Well model
          value: bio_sample_name # call the bio_sample_name method on the Well
        samples: # this field is not in the column_order list above and so will not be included
          type: :array # process the returned value as an array
          value: aliquots_to_show_per_row # well.aliquots_to_show_per_row (might be nil)
          children: # placeholder
            Reagent Plate: # as this column is repeated from above the same column in the sample sheet will be used
              type: :parent_model # call the method on the parent model (well)
              value: plate.plate_number # call well.plate.plate_number again
            Bio Sample Name: # this column is also repeated from above
              type: :model # this time call a method on the Sample
              value: bio_sample_name # call sample.bio_sample_name
```

### Version

As of SMRT-Link v13, a new format of sample sheet has been introduced. Due to the complex nature of
the sample sheet, the `version` key has been introduced to allow different versions of the
sample sheet to be generated.

If the `version` key is not present, the sample sheet will be generated in the more traditional CSV
format using the `column_order` and `fields` as above.

If the `version` key is present, the sample sheet will be generated in the appropriate format for
that version. The `version` key should be a string that matches the `CSV Version` of the sample
sheet as defined in the SMRT Link User Guide for that version.

The implementation of this can be found in [app/models/pacbio/run.rb](/app/models/pacbio/run.rb).  
For `CSV Version 1`, as introduced in SMRT-Link v13, the sample sheet is generated in
[app/exchanges/run_csv/pacbio_sample_sheet_v1.rb](/app/exchanges/run_csv/pacbio_sample_sheet_v1.rb).
