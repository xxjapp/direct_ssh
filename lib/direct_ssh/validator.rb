#!/usr/bin/env ruby
# encoding: UTF-8
#

module Validator
    attr_reader :direct

    def initialize
        @direct = true
    end

    def start(host, user, options={}, &block)
        return Net::SSH.start(host, user, options, block)
    rescue Net::SSH::AuthenticationFailed
        @direct = false

        3.times {
            options[:password] = ask("#{user}@#{host}'s password: ") { |q| q.echo = false }

            begin
                return Net::SSH.start(host, user, options, block)
            rescue Net::SSH::AuthenticationFailed
            end
        }

        raise Net::SSH::AuthenticationFailed, 'Permission denied, please try again.'
    end
end
