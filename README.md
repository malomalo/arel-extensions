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

Just `require 'arel-extensions'` and use `Arel` / `ActiveRecord` as you normally
would.

It adds the methods and nodes below to `Arel::Attributes::Attribute` and to
`ActiveRecord` relations. Most operators generate PostgreSQL-specific SQL.

Attribute-level helpers are used through an Arel attribute, e.g.
`Model.arel_table[:column]`, typically inside `where` or `order`.

## What it adds

### `DISTINCT ON` (ActiveRecord)

Added to relations (and as a class method via `Model.distinct_on`):

```ruby
User.distinct_on(:email)          # SELECT DISTINCT ON (users.email) ...
User.distinct_on(:a, :b)          # DISTINCT ON (users.a, users.b)
```

`uniq_on` is an alias of `distinct_on`.

### Ordering with NULLS FIRST / LAST

```ruby
col = User.arel_table[:name]
User.order(col.asc(:nulls_last))    # ... ORDER BY users.name ASC NULLS LAST
User.order(col.desc(:nulls_first))  # ... ORDER BY users.name DESC NULLS FIRST
```

A `RANDOM()` ordering node is also provided.

### Array predicates

```ruby
tags = Post.arel_table[:tags]
tags.contained_by(other)   # tags <@ other
tags.excludes(other)       # NOT (tags @> other)
```

### JSON / JSONB predicates

```ruby
data = User.arel_table[:data]

data.key('name')            # data #>'{name}'   (aliases: data['name'], data.index('name'))
data.dig('address', 'zip')  # data #>'{address,zip}'
data.has_key('name')        # data ? 'name'
data.has_keys('a', 'b')     # data ?& array['a','b']
data.has_any_key('a', 'b')  # data ?| array['a','b']
data.cast_as('int')         # (data)::int
```

### Full-text search

```ruby
body = Article.arel_table[:body]
body.ts_query('quick & fox')          # to_tsvector(body) @@ to_tsquery('quick & fox')
body.ts_query('quick & fox', 'english')
```

Nodes for `to_tsvector`, `to_tsquery`, `@@` (`TSMatch`), `ts_rank`, and
`ts_rank_cd` are available for building ranking expressions.

### GIS predicates (optional)

```ruby
area = Place.arel_table[:area]
area.intersects(value)   # ST_Intersects(area, value)
area.within(value)       # ST_Within(area, value)
```

`value` may be an Arel node, an RGeo geometry, a WKT/WKB string, or a GeoJSON
hash. Anything other than an Arel node requires the
[`rgeo`](https://github.com/rgeo/rgeo) gem, so add it to your Gemfile if you use
these:

    gem 'rgeo'

### Binary values

`BinaryValue` and `HexEncodedBinaryValue` nodes for embedding binary data
(escaped `bytea` and `\x`-encoded hex, respectively).