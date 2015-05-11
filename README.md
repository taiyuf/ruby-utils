# Utils

Utilities module for ruby with rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'utils',     '~> 0.0.5', github: 'taiyuf/ruby-utils'
```

## Usage

### Utils::Configuration

```ruby
require 'utils'
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

### Utils::HttpClient

Return Net::HTTPOK object.

```ruby
require 'utils/http_client'
include HttpClient

# GET
res = GET url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH

# POST
res = POST url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH

# PUT
res = PUT url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH

# DELETE
res = DELETE url: URL_STRING, params: PARAMS_HASH, headers: HEADERS_HASH, basic_auth: BASIC_AUTH_HASH

puts res.body
```

parammeters:

* url (required):      String object.
* params (option):     Hash object of the parameters.
* headers (option):    Hash object of the headers.
* basic_auth (option): Hash object of the basic authentication infomation. user_name and password keys are required.

## Contributing

1. Fork it ( https://github.com/taiyuf/ruby_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
