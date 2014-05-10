# Norm

Norm is Not an ORM.

It is an experiment in building the minimal useful API to a PostgreSQL database.

It's also not ready for public consumption, but I feel as though finally making
it public will:

1. Allow me to talk to more than the few people I've spoken to about it.
2. Allow others who happen upon this repository to provide unsolicited feedback.
3. Encourage or discourage me from doing further work in this direction, based
   at least partly on the reaction from the community.

## Installation

Don't. No, seriously. It's not ready for consumption yet. I'm also building a
sample application which will help guide future API decisions or maybe prove
that this entire idea is either useless or crazy or both. This is just
something I had to build just to get the idea out of my head, finally. I've been
talking with people about something at least a little bit like this for at least
two years now.

## Usage

Norm only expects you to understand three key concepts in order to use it
effectively:

1. `Norm::Record` - Subclass this class to make a class that supports setting a
   collection of attributes. Attributes are declared with the `attribute`
   keyword, requiring an attribute name and an attribute loader. Loaders must
   respond to `#load`, receiving the object to be loaded and any special
   parameters that govern loading. Return value must be an object which returns
   a PostgreSQL literal string representation of itself on `#to_s`.
2. `Norm::SQL` - Contains convenience methods for SELECT, INSERT, UPDATE, and
   DELETE statements. Also the namespace under which all types of statements
   (and statement fragments) live. These objects are composable. They respond to
   `#sql` and `#params`, returning SQL with placeholders in the form of `$?` and
   the corresponding parameters for this SQL. Like attributes, these parameters
   must return a valid PostgreSQL literal string representation on `#to_s`.
3. `Norm::Repository` - These are where records are stored to and fetched from.
   A repository knows how to identify records in its backend store based on
   primary keys: one or more attributes that constitute a unique identifier for
   a record. It's also associated with a specific record class, so that it knows
   how to instantiate the records from the DB. Repositories have, at minimum,
   these methods:
     * `all` - Returns all records in the repository.
     * `fetch(*keys)` - Returns a single record based on its primary key(s).
     * `insert(record)` - Inserts a single record
     * `update(record)` - Updates a single record
     * `delete(record)` - Deletes a single record
     * `mass_[insert|update|delete](*records)` - Multiple-record variants  
   All other queries are separate methods on the repository, with a specific
   method signature that determines how they should be used and shows their
   intent.

## Philosophy

Norm tries very hard to place the focus on messages and interfaces as opposed
to object kinds. You'll see very little in the way of "is_a?" calls in the
code, and the bulk of the object interactions are done via very small APIs.

Norm is also aiming to be much smaller than ActiveRecord in terms of code size.
As of this writing, it's around 1700 lines, which is something like 10% of the
size of ActiveRecord if you include ActiveModel, and far, far smaller if you
include all of ActiveRecord's dependencies.

Speaking of dependencies, Norm should end up with very few. Right now, we
require the "pg" gem, for obvious reasons, and Mike Perham's excellent
connection_pool gem. I don't anticipate that list to grow much.

There are a lot of features that Norm doesn't have. This is by design. A core
principle as I've been working on it has been to build the minimal thing that
could possibly work -- the thing that other, more "magical" things can be
derived from. For instance, if you take a look at the basic PostgreSQLRepository
you'll see that it expects subclasses to implement
`[select|insert|update|delete]_statement` methods, which are used as the base
of more complicated queries. From this, we can derive a class that instead
supports specification of a table name, and which has its methods implemented
accordingly.

## Contributing

1. Fork it ( http://github.com/ernie/norm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
