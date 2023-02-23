# Todo

## Questions

What to do when there are no pools given for a well/ would this ever be possible

Are `library` pool types required to be added to a well? If not, `pacbio_well_libraries` could be removed maybe?

Can the same pool be added to two wells on the same run/ not on the same run

Do we want to keep plate/ well/ pool CRUD API resources?

## Tests

`runs_spec.rb`
- Check run/ plate/ well/ well_pools:  create/ update/ destroy
- when no pools in well
- when run values are invalid
- add a library type pool to the pools list? / are libraries added to run wells
- same pool to two wells?

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
