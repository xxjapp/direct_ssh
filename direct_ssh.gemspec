# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'direct_ssh/version'

Gem::Specification.new do |spec|
  spec.name          = "direct_ssh"
  spec.version       = DirectSsh::VERSION
  spec.authors       = ["Xia Xiongjun"]
  spec.email         = ["xxjapp@gmail.com"]
  spec.description   = %q{In order to use SSH or SCP without the need to enter password every time, this gem will create public/private ssh rsa keys if they do not exist and send public key to remote server automatically only if necessary.}
  spec.summary       = %q{Use SSH or SCP directly without the need to enter password every time}
  spec.homepage      = %q{https://github.com/xxjapp/direct_ssh}
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "net-ssh", "~> 2.6"
  spec.add_runtime_dependency "net-scp", "~> 1.1"
  spec.add_runtime_dependency "highline", "~> 1.7.10"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
