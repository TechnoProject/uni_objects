#!/usr/local/bin/ruby
#encoding: utf-8

require 'uni_objects'
require '../test/create_test_data'

@session = UniObjects::open('localhost','user','passwd','/usr/uv/UVUSR')
create_table_users
create_data_users
create_table_customers
create_data_customers
@session.quit

