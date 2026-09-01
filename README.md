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

# Keys in a Object
data['name']                # data #> array['name']
data.key('name')            # data #> array['name']
data.index('name')          # data #> array['name']

# Integer index in a Array
data[0]                     # data #> array['0']
data.key(0)                 # data #> array['0']
data.index(0)               # data #> array['0']

# Dig and other operators
data.dig('address', 'zip')  # data #> array['address','zip']
data.dig('tags', -1)        # data #> array['tags','-1']
data.has_key('name')        # data ? 'name'
data.has_keys('a', 'b')     # data ?& array['a','b']
data.has_any_key('a', 'b')  # data ?| array['a','b']
```

A segment may be an integer, which PostgreSQL reads as an array index (negative
counts from the end); out of range yields `NULL`.

Path segments are quoted, so they are safe to build from untrusted input.
PostgreSQL folds the array back to `'{address,zip}'::text[]`, so expression
indexes written against the literal form still match.

### Casting

```ruby
User.arel_table[:id].cast_as('text')            # (users.id)::text
User.arel_table[:created_at].cast_as('date')    # (users.created_at)::date
data.dig('age').cast_as('int')                  # (data #> array['age'])::int
```

A type name can't be quoted or bound, so `cast_as` accepts only something that
looks like one; optionally schema qualified, with a modifier. For example:
`text`, `varchar(255)`, `numeric(10,2)`, `timestamp(6) with time zone`,
`int[]`, `public.geometry`. An `ArgumentError` will be raised otherwise.

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