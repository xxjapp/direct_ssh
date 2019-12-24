#!/usr/bin/env ruby
# encoding: UTF-8

require 'fileutils'
require 'base64'

module KeyHandler
    def self.send_key_to_remote(ssh)
        ssh_public_key = get_ssh_public_key.chomp
        send_ssh_public_key_to_remote(ssh, ssh_public_key)
    end

    ################################################################
    # local ssh key process

    # get public key, create it if not exists
    def self.get_ssh_public_key
        if !File.exists?(Dir.home + '/.ssh/id_rsa.pub')
            create_ssh_files
            chmod_ssh_files

            private_key = OpenSSL::PKey::RSA.new(2048)
            public_key  = get_public_key(private_key.public_key)

            File.write(Dir.home + '/.ssh/id_rsa',     private_key)
            File.write(Dir.home + '/.ssh/id_rsa.pub', public_key)

            return public_key
        end

        IO.read(Dir.home + '/.ssh/id_rsa.pub')
    end

    def self.create_ssh_files
        FileUtils.mkdir Dir.home + '/.ssh'
        FileUtils.touch Dir.home + '/.ssh/id_rsa'
        FileUtils.touch Dir.home + '/.ssh/id_rsa.pub'
        FileUtils.touch Dir.home + '/.ssh/authorized_keys'
        FileUtils.touch Dir.home + '/.ssh/known_hosts'
    end

    # see: http://www.noah.org/wiki/SSH_public_keys
    def self.chmod_ssh_files
        FileUtils.chmod 0700, Dir.home + '/.ssh'
        FileUtils.chmod 0600, Dir.home + '/.ssh/id_rsa'
        FileUtils.chmod 0644, Dir.home + '/.ssh/id_rsa.pub'
        FileUtils.chmod 0644, Dir.home + '/.ssh/authorized_keys'
        FileUtils.chmod 0644, Dir.home + '/.ssh/known_hosts'
    end

    # see: http://www.rubydoc.info/github/delano/rye/Rye/Key.public_key_to_ssh2
    def self.get_public_key(public_key)
        authtype = public_key.class.to_s.split('::').last.downcase
        b64pub   = Base64.encode64(public_key.to_blob).strip.gsub(/[\r\n\t ]/, '')
        user     = ENV['USER']
        host     = ENV['HOSTNAME']
        host     = ENV['COMPUTERNAME'] if host == nil
        "ssh-%s %s %s@%s" % [authtype, b64pub, user, host]
    end

    ################################################################
    # remote ssh key process

    def self.is_windows?(ssh)
        ssh.exec!("echo %os%").chomp != "%os%"
    end

    def self.send_ssh_public_key_to_remote(ssh, key)
        is_win = is_windows?(ssh)

        if !remote_file_exists?(ssh, '~/.ssh/authorized_keys')
            remote_create_ssh_files(ssh, is_win)
            remote_chmod_ssh_files(ssh, is_win)
        end

        remote_append_key(ssh, key, is_win)
    end

    def self.remote_file_exists?(ssh, path)
        # windows & linux       OK
        # path including '~/'   OK
        ssh.exec!("[ ! -f #{path} ] && echo NOT_EXIST").empty?
    end

    def self.remote_create_ssh_files(ssh, is_win)
        if is_win
            ssh_exec!(ssh, 'mkdir .ssh')
            ssh_exec!(ssh, 'touch .ssh\id_rsa')
            ssh_exec!(ssh, 'touch .ssh\id_rsa.pub')
            ssh_exec!(ssh, 'touch .ssh\authorized_keys')
            ssh_exec!(ssh, 'touch .ssh\known_hosts')
        else
            ssh_exec!(ssh, 'mkdir ~/.ssh')
            ssh_exec!(ssh, 'touch ~/.ssh/id_rsa')
            ssh_exec!(ssh, 'touch ~/.ssh/id_rsa.pub')
            ssh_exec!(ssh, 'touch ~/.ssh/authorized_keys')
            ssh_exec!(ssh, 'touch ~/.ssh/known_hosts')
        end
    end

    # see: http://www.noah.org/wiki/SSH_public_keys
    def self.remote_chmod_ssh_files(ssh, is_win)
        if is_win
            # puts "NOTE 1: The default mode on windows should work"
            # puts "NOTE 2: 'chmod' is not available or doesn't work on windows."
            # puts "  If password asked, try to handle according to"
            # puts "  https://social.technet.microsoft.com/Forums/Azure/en-US/e4c11aed-1d8b-4ff4-89ad-c90c62e13ce0/ssh-asking-for-password-even-i-have-private-key"
            # puts "  and log file C:\\ProgramData\\ssh\\logs\\sshd.log"
        else
            ssh_exec!(ssh, 'chmod 700 ~/.ssh')
            ssh_exec!(ssh, 'chmod 600 ~/.ssh/id_rsa')
            ssh_exec!(ssh, 'chmod 644 ~/.ssh/id_rsa.pub')
            ssh_exec!(ssh, 'chmod 644 ~/.ssh/authorized_keys')
            ssh_exec!(ssh, 'chmod 644 ~/.ssh/known_hosts')
        end
    end

    # append public_key to remote '~/.ssh/authorized_keys'
    def self.remote_append_key(ssh, key, is_win)
        if is_win
            ssh_exec!(ssh, "echo #{key} >> .ssh\\authorized_keys")
        else
            ssh_exec!(ssh, "echo #{key} >> ~/.ssh/authorized_keys")
        end
    end

    def self.ssh_exec!(ssh, cmd)
        # puts "# #{cmd}"
        res = ssh.exec! cmd
        # puts res.force_encoding('SJIS').encode('UTF-8')
        res
    end
end
