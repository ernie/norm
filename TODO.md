# Stuff left to do before release

* Typecasting for repo/statement/???
* More loaders
* Context/Transaction support
* Error handling/re-raising

# Thoughts on remaining stuff

## Typecasting for repo/statement

I'm inclined to build a "generic" Loader that has a key for each attribute type
inside the Norm::Attribute namespace, as a convenience for use in a repository.
On the other hand, wouldn't an ideal situation for use in custom repo methods
be to somehow specify the types in the method definitions? I wonder if we could
use keyword arguments for this. Is this even the place for this type of work?

Maybe we want this kind of work, like attribute sanitization, to be performed at
the controller level in a Rails app. If the user wants to do some work in their
repos to enable something different, they would be welcome to, of course, but
that would be an API design decision they would make.

## Context/Transaction support

Would this work?

Add ConnectionManager#with_transaction, which will return a context that is tied
to the specific connections supplied to with_transaction. If a PG::Error is
raised inside the block, any connections on which a transaction was started will
be rolled back, and the error re-raised unless it's a Rollback error (similar to
ActiveRecord transactions). The object yielded to the with_transaction block
would be composable -- should look essentially like a ConnectionManager to the
block inside, meaning the "with_connection(s)" calls that map to an already-open
connection would return that same connection, therefore performing their work
in the connection with the open transaction. with_transaction calls on this
object would result in savepoints for the connections referenced (if already
in a transaction).

## Error handling

So, we need to return records on the default repository select methods
(all/fetch). Other methods, it seems, should return a more useful result object.
Thinking there should be a method on the PostgreSQL repository that takes a
block and always returns an object of (say) Norm::Result. It'll have stuff like
Result#success? and Result#errors, which would have a processed error object of
some kind. The general idea would be to return a successful Result if no errors
were raised, but rescue PG::Error and return an unsuccessful result with
processed errors for use in (for instance) a form. We can use the error_fields
of the PG::Error#result for processing.

The Result object should also implement to_a and to_ary, to allow something like

```ruby
@post = formify(repository.fetch(params[:id]))
@post.set_attributes params[:post]
success, errors = repository.update(@post)
if success
  redirect_to edit_post_path(@post)
else
  @post = errors
  render :edit
end
```
