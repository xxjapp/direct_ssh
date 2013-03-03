#!/usr/bin/env ruby
# encoding: UTF-8
#

require 'direct_ssh/validator'
require 'direct_ssh/key_handler'

module DirectSsh
    def self.start(host, user, options={}, &block)
        validator = Validator.new
        ssh       = validator.start(host, user, options)

        KeyHandler.send_key_to_remote(ssh) if !validator.direct

        if block_given?
            retval = yield ssh
            ssh.close
            return retval
        else
            return ssh
        end
    end
end
