# Stuff left to do before release

* More loaders, and possibly improved parsing support
* Error handling
* Reconnect logic and setting client vars for consistency
* Sample application

# Thoughts on remaining stuff

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

On second thought, that's gonna conflate the responsibilities of the repository
and the thing that is responsible for handling errors of various types. There's
all kinds of considerations if we expect repository methods to potentially
rescue errors, not the least of which is that you can't effectively make the
repository methods interact inside of transactions.

At this point I'm thinking what we want to do here is to allow the methods which
modify data ([insert|update|delete]_records to start with) to rescue
Norm::ConstraintError (raised when we encounter a
PG::IntegrityConstraintViolation from the underlying PG connection) and return
a result object appropriate to it. The ConstraintError itself should collect
data from the PG::Result contained in the PG error and make it more accessible.
Whether or not we do anything more than this to try to map it to attribute names
and so on is up for debate but I'm leaning toward no. The idea should be that
you can name your constraints appropriately enough that you can create mappings
for them to usable error messages, or even (God forbid) ActiveModel::Errors.
