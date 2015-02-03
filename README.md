# Utils

Utilities module for ruby with rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install utils

## Usage

### Utils::Configuration

```ruby
require 'utils/configuration'
include Utils::Configuration

@config = get_config
```

Return the hash from yaml file (config/config_common.yml, config/config_secret.yml).

#### config/config_common.yml

Please set the not secure value in this file.

#### config/config_secret.yml

Please set the secure value with RAILS_ENV and add this file to .gitignore.
return the hash which RAILS_ENV's value.

ex) sample config_secret.yml

```
production:
  mysql:
    user_name: hoge
    password: hoge

development:
  mysql:
    user_name: foo
    password: foo

test:
  mysql:
    user_name: bar
    password: bar
```

if RAILS_ENV == 'production', return this hash.

```ruby
{ 'mysql' => { 'user_name' => 'hoge', 'password' => 'hoge' } }
```

## Contributing

1. Fork it ( https://github.com/taiyuf/ruby_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
