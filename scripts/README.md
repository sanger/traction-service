# Scripts README

## Sample Sheet Downloads

Sample sheets can be downloaded en masse for debugging and development purposes using the `download_sample_sheets` command.

The command should be run from the project-root directory. For convenience, a `.env` file can be created containing the hostnames for the various environments. The existing `scripts/.env.example` file can be renamed to `scripts/.env` and populated with the appropriate hostnames.

To download all the sheets for the PacBio seed data in the development environment, run:

```sh
./scripts/download-sample-sheets 1 8 development
```

To download all the sheets for the PacBio seed data in the UAT environment, run:

```sh
source scripts/.env
./scripts/download-sample-sheets 1 8 uat $TRACTION_UAT_HOST
```

Downloaded sample sheets will be saved to `storage/<directory>`, ie `storage/development/` or
`storage/uat/` for the examples above.
