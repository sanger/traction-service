# Todo

## To Confirm

Run create/ update response
- include run info
- anything else to be included?

## Tests

`runs_spec.rb`
- when no pools in well
- when run values are invalid
- same pool to two wells -  allowed
- update run info
- update run state

`run_resource.rb`
- wells_attributes
- construct_resources!
- fetchable_fields
- wells_attributes=
- permitted_wells_attributes
- add back `filters` ?
- add back `self.default_sort` ?
- is `records_for_populate` needed?


## Validation

- when two pools in the same well have the same library tag
ActiveModel::Error attribute=tags, type=are not unique within the libraries for well A2, options={}>
This error is currently ignored - throw instead?

- when the pool doesn't exist
This error is currently ignored - throw instead?

- add well validation to factory?
e.g. when the wells list is empty, but don't think this would ever happen from the UI


## Other

Remove unused CRUD operations

Possibly remove `pacbio_well_libraries`

Remove well `_deprecated` attributes


# Done

Allow Well update:
- add wells (DONE)
- remove wells (DONE)
- update wells (DONE)
- add pools to well (DONE)
- remove pools from well (DONE)

Test `run_factory.rb` (DONE)
Test `run.rb` (DONE)


# Learnings

- on update, when only sending some of the well attributes, it only updates those and the others remain unchanged

- on create, if not all well attribtes exist, it still creates the wells it can, so does not error
