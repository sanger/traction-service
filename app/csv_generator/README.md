# Sample Sheet Generator

The sample sheets are defined through configuration in
[/config/pipelines/](/config/pipelines/)`{pipeline}.yml` for ONT and PacBio.

This configuration is parsed using
[/app/csv_generator/](/app/csv_generator/)`{pipeline}_sample_sheet.rb` as appropriate.

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
- [constant] => take the constant and applies the method chain to it e.g DateTime.now