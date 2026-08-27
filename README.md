# Arel Extensions

Adds support for missing SQL operators and functions to Arel for ActiveRecord.

## Installation

Add this line to your application's Gemfile:

    gem 'arel-extensions', require: 'arel/extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arel-extensions

## Usage

Just `require 'arel-extensions'` and use Arel/ActiveRecord as you normally would!
arel-extensions extends ActiveRecord's query methods in both Arel and ActiveRecord.

### GIS predicates

The GIS predicates (`#intersects` and `#within`) are optional and require the
[`rgeo`](https://github.com/rgeo/rgeo) gem, unless you pass an Arel node. Add it
to your Gemfile if you use them with a geometry, WKT/WKB string, or GeoJSON hash:

    gem 'rgeo'