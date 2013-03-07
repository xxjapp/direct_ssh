# DirectSsh

In order to use SSH or SCP without the need to enter password every time, this gem will create public/private ssh rsa keys if they do not exist and send public key to remote server automatically only if necessary.

## Installation

Add this line to your application's Gemfile:

    gem 'direct_ssh'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install direct_ssh

## Original Style Examples

Scripts like these

a. scripts which ask password every time

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

can be rewritten like examples in **DirectSsh Style SSH Examples**.

## DirectSsh Style SSH Examples

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

## DirectSsh Style SCP Examples

e. direct_ssh scp example

```ruby
#!/usr/bin/env ruby
# encoding: UTF-8

require 'direct_ssh'
require 'net/scp'

local_path = __FILE__
file_name  = File.basename(local_path)

DirectSsh.start('127.0.0.1', 'user', {:port => 22}) { |ssh|
    # check whether this script file already exists on remote server
    puts ssh.exec!("ls -l /tmp/#{file_name}")

    # upload this script file to '/tmp' of remote server
    ssh.scp.upload!(local_path, '/tmp')

    # check again whether this script file already exists on remote server
    puts ssh.exec!("ls -l /tmp/#{file_name}")

    # download remote file and save it using another name
    ssh.scp.download!("/tmp/#{file_name}", "./#{file_name}.download")
}
```

## Shell Commands

The `direct_ssh` shell command checks status of ssh connection to the remote server. It will ask password and send public key to remote server if necessary.

After ssh connection created successfully, The `cat /etc/*-release` command will be executed.

```text
Usage: direct_ssh user@host [-p port]
 - default port 22 will be used if you leave it off
```

The `direct_scp` shell command uses direct_ssh to upload or download files.

```text
Usage:
1) upload file to remote server
 # direct_scp [-r] [-p port] local_file user@host:remote_file
2) download file from remote server
 # direct_scp [-r] [-p port] user@host:remote_file local_file
3) print this message
 # direct_scp -h

default port 22 will be used if you leave it off
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
