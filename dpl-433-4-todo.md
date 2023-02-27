# Todo

Allow Well update:
- add wells (DONE)
- remove wells (DONE)
- update wells id
- create and update wells in one request
- add pools to well
- remove pools from well
- update well pools
- pool does not exist (DONE?)

Run read:
- include well data

Remove unused CRUD operations

Possibly remove `pacbio_well_libraries`


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

`run_factory.rb`
- run accessor
- construct_resources!
- wells_attributes=
- wells_attributes
