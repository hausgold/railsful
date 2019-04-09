# Railsful

[![Build Status](https://travis-ci.com/hausgold/railsful.svg?branch=master)](https://travis-ci.com/hausgold/railsful)
[![Maintainability](https://api.codeclimate.com/v1/badges/280110b88c5de6b6c472/maintainability)](https://codeclimate.com/repos/5cac8bcf6969c376b7007d57/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/280110b88c5de6b6c472/test_coverage)](https://codeclimate.com/repos/5cac8bcf6969c376b7007d57/test_coverage)
[![API docs](https://img.shields.io/badge/docs-API-blue.svg)](https://www.rubydoc.info/gems/railsful)

A small but helpful collection of concerns and tools to create
a restful JSON API compliant Rails application.

## Installation

Add these lines to your application's Gemfile:

```ruby
# fast_jsonapi is used to serialize objects.
gem 'fast_jsonapi'
# kaminari needed for pagination.
gem 'kaminari'

gem 'railsful'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install railsful

## Usage

### Serialization

In order to serialize your objects it is necessary that their serializer follow
the same naming convention and modules as the object to be serialized.

``` ruby
# app/models/some_module/user.rb
module SomeModule
  class User
    ...
  end
end

# app/serializers/some_module/user_serializer.rb
module SomeModule
  class UserSerializer
    ...
  end
end
```

After that you can use `render json: ...` without specifying the serializer:

``` ruby
module SomeModule
  class UserController
    def index
      render json: User.all
    end
  end
end
```

Will result in:

``` json
GET /some_module/users
{
  "data": [
    { "type": "user", "id": 1, "attributes": { ... } },
    { "type": "user", "id": 2, "attributes": { ... } }
  ]
}
```

### Deserialization
For deserialization of jsonapi compliant request all controllers that
inherit from `ActionController` can use the `#deserialized_params` method.

``` ruby
class UsersController < ApplicationController
  def create
    user = User.new(user_params)

    # Return success/fail ...
  end

  private

  def user_params
    deserialized_params.permit(:first_name, :last_name, ...)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hausgold/railsful.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
