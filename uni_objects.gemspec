# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uni_objects/version'

Gem::Specification.new do |spec|
  spec.name          = "uni_objects"
  spec.version       = UniObjects::VERSION
  spec.authors       = ["Techno Project Co., Ltd.", "8Clouds, Inc."]
  spec.email         = ["ruby-project@8clouds.co.jp"]
  spec.description   = '4D DAM API Library for Ruby, bridge to 4D DAM C Library.'
  spec.summary       = %q{4D DAM API library for Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"
  
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  #spec.extensions    = ["ext/uni_objects/extconf.rb"]

  spec.post_install_message = <<EOS
インストール先へ移動し、
以下のコマンドを実行して拡張ライブラリをコンパイルしてください
----
$ bundle install
$ rake compile
---
EOS

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 4.7.5"
  spec.add_development_dependency "rake-compiler"
end
