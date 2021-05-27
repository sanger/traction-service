# Traction service

[![Build Status](https://travis-ci.org/sanger/traction-service.svg?branch=devel)](https://travis-ci.org/sanger/traction-service)

Rails app which exposes a RESTful API.

## Requirements

1. Ruby (check `.ruby-version` for the version) and ruby version manager
1. Bundler `gem install bundler`
1. Graphviz (for mac OS `brew install Graphviz`)
1. OpenSSL
1. MySQL `brew install mysql`

## Installation

1. Run `bin/setup`

This will:

- Run bundle install
- Create copies of any .example files
- Create the database

## Database setup

The database should have been generated as part of the installation step above.
If you need to create the database afresh: `bundle exec rails db:setup`.

To create a set of enzymes (needed for saphyr dummy runs): `bundle exec rails enzymes:create`

To create the first set of tags (needed for pacbio and ont dummy runs): `bundle exec rails tags:create`

To fetch tags from SS: `bundle exec rails tags:fetch`

To update tags for an ONT plate which has tags wrongly assigned by row rather than column: `BARCODES=barcode1,barcode2... bundle exec rails tags:reorder`

To create pacbio dummy runs: `bundle exec rails pacbio_runs:create`

To create saphyr dummy runs: `bundle exec rails saphyr_runs:create`

To create ont dummy data: `bundle exec rails ont_data:create`

## Database drop

To drop the database `bundle exec rails db:drop`


## Tests
To run the unit tests run rspec. `bundle exec rspec`

We use rubocop to keep the code clean `bundle exec rubocop`


## Running

To run the rails application `bundle exec rails s`

When running with Traction-UI, UI expects the service to be on port 3100. `PORT=3100 rails s`


## Messages - RabbitMQ

Sending messages is disabled by default but if you would like to test messages, install a broker
(RabbitMQ) and update the config in `config/bunny.yml` by enabling the development settings.

After installing RabbitMQ, you will need to create the exchange you will be sending messages over.
You can do this by issuing a command in your terminal such as

    rabbitmqadmin declare exchange name="bunny.examples.exchange" type="topic"

making sure you match the exchange name with the one specified in `config/bunny.yml`.

A web interface to administrate RabbitMQ is always available at [http://localhost:15672/](http://localhost:15672/) once the service is running.

## Miscellaneous

### Git commit hook

You may wish to enable the provided git commit hook if you want to be notified of rubocop issues in the files you've edited before they are committed.
To do this, refer to the documentation in `.githooks/README.txt`.

### Rails

To see all the commands available from rails: `bundle exec rails -T`

### ERD

An ERD was created using the `rails-erd` gem by executing: `bundle exec erd`

![ERD](erd.jpg "ERD")

### GraphQL

The documentation for GraphQL can be accessed by navigating to [http://localhost:3000/v2/docs](http://localhost:3000/v2/docs) while the development rails server is running.
This documentation can be updated by running the following commands:

1. Update the stored schema: `bundle exec rails graphql:schema:dump`
1. Update the documentation: `bundle exec rails graphql:docs:generate`

## Releases

#### UAT
On merging a pull request into develop, a release will be created with the tag/name `<branch>/<timestamp>`

#### PROD
Update `.release-version` with major/minor/patch. On merging a pull request into master, a release will be created with the release version as the tag/name

See Confluence for further information
