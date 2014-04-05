# Norm

Norm is not an ORM.

It is an experiment in building the minimal useful API to a PostgreSQL database.

## Installation

Add this line to your application's Gemfile:

    gem 'norm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install norm

## Usage

Norm only expects you to understand three key concepts in order to use it
effectively:

1. `Norm::Record` - Extended on any Ruby class to make this class support a
   collection of attributes. Attributes are declared with the `attribute`
   keyword, requiring an attribute name and an attribute loader. Loaders must
   respond to `#load`, receiving the object to be loaded and any special
   parameters that govern loading. Return value must be an object which returns
   a PostgreSQL literal string representation of itself on `#to_s`.
2. `Norm::Statement` - Contains convenience methods for SELECT, INSERT, UPDATE,
   and DELETE statements. Also the namespace under which all types of statements
   (and statement fragments) live. These objects are composable. They respond to
   `#sql` and `#params`, returning SQL with placeholders in the form of `$?` and
   the corresponding parameters for this SQL. Like attributes, these parameters
   must return a valid PostgreSQL literal string representation to `#to_s`.
3. `Norm::ExecutionContext` - This is where statements get executed.

## Contributing

1. Fork it ( http://github.com/ernie/norm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
