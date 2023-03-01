# Todo

Run create/ update response
- include run info
- anything else?

Allow Well update:
- add wells (DONE)
- remove wells (DONE)
- update wells (DONE)
- add pools to well (DONE)
- remove pools from well (DONE)
- add well validation to factory?

- when only sending some of the well attributes, does it delete all the others?


## Tests

`runs_spec.rb`
- when no pools in well
- when run values are invalid
- same pool to two wells -  allowed
- update run info
- update run state

`run.rb`
- delegate :wells_attributes=, :construct_resources!, to: :run_factory
- run_factory

`run_resource.rb`
- wells_attributes
- construct_resources!
- fetchable_fields
- wells_attributes=
- permitted_wells_attributes
- add back `filters` ?
- add back `self.default_sort` ?
- is `records_for_populate` needed?

`run_factory.rb` (DONE)


- when two pools in the same well have the same library tag
ActiveModel::Error attribute=tags, type=are not unique within the libraries for well A2, options={}>
currently ignored - throw error instead?

- when the pool doesn't exist
currently ignored - throw error instead?


# Other

Remove unused CRUD operations

Possibly remove `pacbio_well_libraries`

Remove well `_deprecated` attributes
