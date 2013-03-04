# DirectSsh

In order to use ssh without the need to enter password everytime, this gem will create public/private rsa keys if they do not exist and send public key to remote server

## Installation

Add this line to your application's Gemfile:

    gem 'direct_ssh'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install direct_ssh

## Usage

Scripts like these

a. scripts which ask password everytime

```ruby
#!/usr/bin/env ruby
# encoding: UTF-8

require 'net/ssh'
require 'highline/import'

host = '127.0.0.1'
user = 'user'

options = {}
options[:password] = ask("#{user}@#{host}'s password: ") { |q| q.echo = false }

Net::SSH.start(host, user, options) { |ssh|
    puts ssh.exec!('cat /etc/*-release')
}
```

b. scripts which expose password directly

```ruby
#!/usr/bin/env ruby
# encoding: UTF-8

require 'net/ssh'

Net::SSH.start('127.0.0.1', 'user', {:password => 'password'}) { |ssh|
    puts ssh.exec!('cat /etc/*-release')
}
```

can be rewritten like this

c. direct_ssh example with block form

```ruby
#!/usr/bin/env ruby
# encoding: UTF-8

require 'direct_ssh'

DirectSsh.start('127.0.0.1', 'user') { |ssh|
    puts ssh.exec!('cat /etc/*-release')
}
```

or

d. direct_ssh example without block

```ruby
#!/usr/bin/env ruby
# encoding: UTF-8

require 'direct_ssh'

ssh = DirectSsh.start('127.0.0.1', 'user')
puts ssh.exec!('cat /etc/*-release')
ssh.close
```

## Shell

The direct_ssh shell command checks status of ssh connection to the remote server. It will ask password and send public key to remote server if neccessary.

After ssh connection created successfully, The `cat /etc/*-release` command will be executed.

```text
Usage: direct_ssh user@host [-p port]
 - default port 22 will be used if you leave it off
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Links

1. ruby gem [net-ssh](https://rubygems.org/gems/net-ssh)
2. ruby gem [highline](https://rubygems.org/gems/highline)
3. ruby gem [direct_ssh](https://rubygems.org/gems/direct_ssh)
