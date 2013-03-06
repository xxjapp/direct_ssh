# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'direct_ssh/version'

Gem::Specification.new do |spec|
  spec.name          = "direct_ssh"
  spec.version       = DirectSsh::VERSION
  spec.authors       = ["Xia Xiongjun"]
  spec.email         = ["xxjapp@gmail.com"]
  spec.description   = %q{Create public/private rsa keys if they do not exist and send public key to remote server}
  spec.summary       = %q{Use ssh without the need to enter password everytime}
  spec.homepage      = %q{https://github.com/xxjapp/direct_ssh}
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "net-ssh"
  spec.add_runtime_dependency "net-scp"
  spec.add_runtime_dependency "highline"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
