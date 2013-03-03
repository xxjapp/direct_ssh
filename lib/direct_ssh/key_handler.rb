#!/usr/bin/env ruby
# encoding: UTF-8
#

module KeyHandler
    def self.send_key_to_remote(ssh)
        ssh_public_key = get_ssh_public_key
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
        FileUtils.mkdir_p Dir.home + '/.ssh'
        FileUtils.touch   Dir.home + '/.ssh/id_rsa'
        FileUtils.touch   Dir.home + '/.ssh/id_rsa.pub'
        FileUtils.touch   Dir.home + '/.ssh/authorized_keys'
        FileUtils.touch   Dir.home + '/.ssh/known_hosts'
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

    def self.send_ssh_public_key_to_remote(ssh, key)
        if !remote_file_exists?(ssh, '~/.ssh/authorized_keys')
            remote_create_ssh_files(ssh)
            remote_chmod_ssh_files(ssh)
        end

        # append public_key to remote '~/.ssh/authorized_keys'
        ssh.exec!("echo '#{key}' >> ~/.ssh/authorized_keys")
    end

    def self.remote_file_exists?(ssh, path)
        ssh.exec!("[ ! -f #{path} ] && echo NOT_EXIST") == nil
    end

    def self.remote_create_ssh_files(ssh)
        ssh.exec!('mkdir -p ~/.ssh')
        ssh.exec!('touch    ~/.ssh/id_rsa')
        ssh.exec!('touch    ~/.ssh/id_rsa.pub')
        ssh.exec!('touch    ~/.ssh/authorized_keys')
        ssh.exec!('touch    ~/.ssh/known_hosts')
    end

    # see: http://www.noah.org/wiki/SSH_public_keys
    def self.remote_chmod_ssh_files(ssh)
        ssh.exec!('chmod 700 ~/.ssh')
        ssh.exec!('chmod 600 ~/.ssh/id_rsa')
        ssh.exec!('chmod 644 ~/.ssh/id_rsa.pub')
        ssh.exec!('chmod 644 ~/.ssh/authorized_keys')
        ssh.exec!('chmod 644 ~/.ssh/known_hosts')
    end
end
