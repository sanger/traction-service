# Sample Sheet Generator

The sample sheets are defined through configuration in
[/config/pipelines/](/config/pipelines/)`{pipeline}.yml` for ONT and PacBio.

This configuration is parsed using
[/app/exchanges/run_csv/](/app/exchanges/run_csv/)`{pipeline}_sample_sheet.rb` as appropriate.

The required format of the sample sheets can be found on page 27 of the [SMRT Link User Guide
v12.0](https://www.pacb.com/wp-content/uploads/SMRT_Link_User_Guide_v12.0.pdf).

Once generated, the sample sheets are uploaded to SMRT Link, a test instance can be found on UAT.

**Note:**

- ONT uses `flowcell` and `sample`
- PacBio uses `well` and `sample`

## Configuration

If the column does not need to be populated for the row_type return empty string.  
If the column does need to be populated then return the value from the object.  
Populating on row_type means that we need to populate it with the object pertaining to the row type
otherwise just populate with the populate with value.  
Some columns need populating for both types with the same method (polymorphism). well position is
different. It would be really difficult to get that from sample.

- `populate[:for]` is either sample or flowcell/well
- `populate[:with]` is either row_type (sample or flowcell/well), sample or flowcell/well

Examples:

```yaml
Is Collection:
type: :model
value: collection?
populate:
  for:
    - :well
    - :sample
  with: :row_type
```

means that is collection needs to be populated for samples and wells but needs to use the method
from sample or well as the answers are different

```yaml
Sample Well:
type: :model
value: position_leading_zero
populate:
  for:
    - :well
    - :sample
  with: :well
```

means that sample well needs to be populated for both samples and wells but needs to use the well
method

Find the instance value for each field

If the field is a:

- [string] => return the value
- [model] => take the value split it by the full stop and recursively send the method to the object
  e.g. it is object.foo.bar will first evaluate foo and then apply bar
- [parent_model] => as above, but for the direct parent of the current model
- [constant] => take the constant and applies the method chain to it e.g DateTime.now

### Functions

Functions are defined for `:model` and `:parent_model` in the models themselves and in
`app/models/concerns/sample_sheet.rb`
