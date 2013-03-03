# DirectSsh

In order to use ssh without the need to enter password everytime,
this gem will create public/private rsa keys if they do not exist
and send public key to remote server

## Installation

Add this line to your application's Gemfile:

    gem 'direct_ssh'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install direct_ssh

## Usage

Scripts like these

1. scripts which ask password everytime

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

2. scripts which expose password directly

    #!/usr/bin/env ruby
    # encoding: UTF-8
    
    require 'net/ssh'
    require 'highline/import'
    
    Net::SSH.start('127.0.0.1', 'user', {:password => 'password'}) { |ssh|
        puts ssh.exec!('cat /etc/*-release')
    }

can be rewritten like this

3. direct_ssh example with block form

    #!/usr/bin/env ruby
    # encoding: UTF-8
    
    require 'direct_ssh'
    
    DirectSsh.start('127.0.0.1', 'user') { |ssh|
        puts ssh.exec!('cat /etc/*-release')
    }

or

4. direct_ssh example without block

    #!/usr/bin/env ruby
    # encoding: UTF-8
    
    require 'direct_ssh'
    
    ssh = DirectSsh.start('127.0.0.1', 'user')
    puts ssh.exec!('cat /etc/*-release')
    ssh.close

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
