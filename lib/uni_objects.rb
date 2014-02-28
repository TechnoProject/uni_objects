RUBY_VERSION =~ /(\d+.\d+)/
require "uni_objects/#{$1}/UniObjects.so"
require "uni_objects/version"
require "uni_objects/uni_verse"

module UniObjects
end
