# Traction service

Rails app which exposes a RESTful API.

## Requirements

1. Ruby (check `.ruby-version` for the version)
1. Bundler

## Installation

1. Install using: `bundle install`
1. Remove the `.example` from the config files in `config` folder

## Database setup

To create the database for a fresh install: `bundle exec rails db:setup`

## Messages - RabbitMQ

Sending messages is disabled by default but if you would like to test messages, install a broker
(RabbitMQ) and update the config in `config/bunny.yml`.

## Miscellaneous

### Rails

To see all the commands available from rails: `bundle exec rails -T`co

### ERD

An ERD was created using the `rails-erd` gem by executing: `bundle exec erd`

![ERD](erd.jpg "ERD")
