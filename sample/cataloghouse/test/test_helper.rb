#encoding: utf-8
require File.expand_path('../../config/environment', __FILE__)
require 'minitest/autorun'
require 'minitest/pride'
require 'create_test_data_uni_verse'

class User < UniObjects::UniVerse
end
class Customer < UniObjects::UniVerse
end

