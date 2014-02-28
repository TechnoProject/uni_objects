require "bundler/gem_tasks"
require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/*_test.rb"
end

require 'rake/extensiontask'
Rake::ExtensionTask.new("uni_objects") do |ext|
  RUBY_VERSION =~ /(\d+.\d+)/
  ext.name="UniObjects"
  ext.lib_dir = "lib/uni_objects/#{$1}"
  ext.config_options << "--with-cflags='-Wall -m32'"
  paths = $LOAD_PATH.collect{|p|"-L#{p}"}.join(" ")
  ext.config_options << "--with-ldflags='-m32 #{paths} -L/usr/lib'"
end
