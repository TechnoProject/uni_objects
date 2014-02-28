#!/usr/local/bin/ruby
#encoding: utf-8

require 'test_helper'

class UniVerseTest < MiniTest::Unit::TestCase

  def setup
    @session = User.open_session
    #@session = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    create_table_users
    create_data_users
    create_table_customers
    create_data_customers
  end

  def teardown
    @session.execute('DELETE.FILE USERS')
    @session.execute('DELETE.FILE CUSTOMERS')
    UniObjects::quitall
  rescue
    session = User.open_session
    session.execute('DELETE.FILE USERS')
    session.execute('DELETE.FILE CUSTOMERS')
    UniObjects::quitall
  end

################################################################################

  def test_init_session
    session = User.init_session
    assert_nil(session)
  end

  def test_open_session
    session = User.open_session
    assert_instance_of(UniObjects::UniSession, session)
  end

  def test_quit_session
    session = User.quit_session
    assert_nil(session)
  end

################################################################################
  
  def test_table_name
    assert_equal("USERS", User.table_name)
    assert_equal("CUSTOMERS", Customer.table_name)
  end

  def test_set_table_name
    assert_equal(false, User.set_table_name(nil))
    assert_equal("USERS", User.set_table_name("USERS"))
  end
  
  def test_fields
    assert_equal(["LAST_NAME", "FIRST_NAME", "GENDER", "DOB"], User.set_fields)
    assert_equal(["LAST_NAME", "FIRST_NAME", "GENDER", "DOB", "RECEIVE_IDS", "ITEM_ID", "SPFL", "SEQ", "COLOR_SIZE1", "COLOR_SIZE2", "RECEIVE_CODE"], Customer.set_fields)
  end

  def test_set_fields
    assert_equal(["LAST_NAME", "FIRST_NAME", "GENDER", "DOB"], User.set_fields)
  end
  
################################################################################

  def test_all
    users = User.all
    assert_equal(Array, users.class)
    assert_equal(5, users.length)
    assert_equal(User, users[0].class)
  end

  def test_all_option_fields
    users = User.all fields: "LAST_NAME"
    assert_equal(Array, users.class)
    assert_equal(5, users.length)
    assert_equal(User, users[0].class)
    assert_equal("SATOU" ,users[0].last_name)
    assert_equal(nil     ,users[0].first_name)
  end

  def test_all_option_with
    users = User.all with: "GENDER=2"
    assert_equal(Array, users.class)
    assert_equal(2, users.length)
    assert_equal(User, users[0].class)
  end

  def test_all_option_when
    customers = Customer.all when: "RECEIVE_CODE=A01"
    # RECEIVE_CODE=A01 のレコードが2件ある
    assert_equal(Array, customers.class)
    assert_equal(2, customers.length)
    assert_equal(Customer, customers[0].class)
    assert_equal(Customer, customers[1].class)
    # マルチバリューはそれぞれ2件、1件ある
    # 1件の場合はHashが返る
    assert_equal(Array ,customers[0].a1_mv.class)
    assert_equal(Hash  ,customers[1].a1_mv.class)
    assert_equal(2 ,customers[0].a1_mv.length)
  end

  def test_all_option_limit
    users = User.all limit: 3
    assert_equal(Array, users.class)
    assert_equal(3, users.length)
    assert_equal(User, users[0].class)
  end

  def test_all_option_options
    users = User.all options: "1"
    assert_equal(Array, users.class)
    assert_equal(1, users.length)
    assert_equal(User, users[0].class)
  end

  def test_all_options
    users = User.all fields: "LAST_NAME", with: "GENDER=2"
    assert_equal(Array, users.class)
    assert_equal(2, users.length)
    assert_equal(User, users[0].class)
    assert_equal("TANAKA" ,users[0].last_name)
    assert_equal(nil      ,users[0].first_name)
  end

  def test_all_record_not_found
    users = User.all with: "GENDER=3"
    assert_equal([], users)
  end

################################################################################

  def test_first
    user = User.first
    assert_equal(User, user.class)
    assert_equal("1", user.to_s)
  end

  def test_first_option_fields
    user = User.first fields: "LAST_NAME"
    assert_equal(User, user.class)
    assert_equal("1", user.to_s)
    assert_equal("SATOU" ,user.last_name)
    assert_equal(nil     ,user.first_name)
  end

  def test_first_option_with
    user = User.first with: "GENDER=2"
    assert_equal(User, user.class)
    assert_equal("4", user.to_s)
  end

  def test_first_option_when
    customer = Customer.first when: "RECEIVE_CODE=A01"
    assert_equal(Customer, customer.class)
    assert_equal("1", customer.to_s)
    # マルチバリューはそれぞれ2件、1件ある
    assert_equal(Array ,customer.a1_mv.class)
    assert_equal(2 ,customer.a1_mv.length)
  end

  def test_first_option_options
    user = User.first options: "2"
    assert_equal(User, user.class)
    assert_equal("2", user.to_s)
  end

  def test_first_options
    user = User.first fields: "LAST_NAME", with: "GENDER=2"
    assert_equal(User, user.class)
    assert_equal("4", user.to_s)
    assert_equal("TANAKA" ,user.last_name)
    assert_equal(nil      ,user.first_name)
  end

  def test_first_record_not_found
    assert_nil(User.first options: "6")
  end

################################################################################

  def test_find_option_hash_id
    user = User.find id: "1"
    assert_equal(User, user.class)
    assert_equal("1", user.to_s)
  end

  def test_find_option_hash_id_recort_not_found
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22003] Record found."){
      user = User.find id: "6"
    }
  end

  def test_find_option_hash_else
    users = User.find with: "GENDER=2"
    assert_equal(Array, users.class)
    assert_equal(2, users.length)
    assert_equal(User, users[0].class)
  end

  def test_find_option_hash_else_record_not_found
    users = User.find with: "GENDER=3"
    assert_nil(users)
  end

  def test_find_option_else
    assert_equal("1", User.find("1").to_s)
  end

  def test_find_option_else_record_not_found
    assert_nil(User.find("6"))
    assert_nil(User.find)
  end

################################################################################

  def test_get_hash_from_list_command
    user = User.get_hash_from_list_command('LIST USERS "1"')
    hash = {"USERS"=>{"_ID"=>"1", "LAST_NAME"=>"SATOU", "FIRST_NAME"=>"Yuma", "GENDER"=>"1", "DOB"=>"19750128"}}
    assert_equal(hash, user)
  end

  def test_get_hash_from_list_command_record_not_found
    assert_nil(User.get_hash_from_list_command('LIST USERS "6"'))
  end

################################################################################

  def test_perform_command
    user = User.perform_command('LIST USERS "1"')
    str = "\r\n\r\n<?xml version=\"1.0\" encoding=\"UTF8\"?>\r\n<ROOT>\r\n<USERS _ID = \"1\" LAST_NAME = \"SATOU\" FIRST_NAME = \"Yuma\" GENDER = \"1\" DOB = \"19750128\"/>\r\n</ROOT>\r\n"
    assert_equal(str, user)
  end

  def test_perform_command_record_not_found
    user = User.perform_command('LIST USERS "6"')
    str = "\r\n\r\n<?xml version=\"1.0\" encoding=\"UTF8\"?>\r\n<ROOT></ROOT>\r\n\"6\" not found.\r\n"
    assert_equal(str, user)
  end

################################################################################

  def test_create_class
    assert_equal(5, User.all.length)
    assert_nil(User.find("6"))
    newuser = {id: "6", last_name: "Newlast", first_name: "Newname", gender: "1", dob: "19870601"}
    user = User.create(newuser)
    assert_equal(true, user)
    assert_equal(6, User.all.length)
    assert_equal("6", User.find("6").to_s)
  end

  def test_create_class_only_error_column
    # カラム名が正しくない場合はcreateされない
    assert_equal(5, User.all.length)
    assert_nil(User.find("6"))
    newuser = {id: "6", name: "Newlast"}
    user = User.create(newuser)
    assert_equal(false, user)
    assert_equal(5, User.all.length)
    assert_nil(User.find("6"))
  end

  def test_create_class_exist_error_column
    # 正しいカラム名のみcreate対象になる
    assert_equal(5, User.all.length)
    assert_nil(User.find("6"))
    newuser = {id: "6", name: "Newlast", first_name: "Newname"}
    user = User.create(newuser)
    assert_equal(true, user)
    assert_equal(6, User.all.length)
    assert_equal("6", User.find("6").to_s)
  end

################################################################################

  def test_update_class
    assert_equal(5, User.all.length)
    updateuser = {id: "1", last_name: "Newlast"}
    user = User.update(updateuser)
    assert_equal(true, user)
    assert_equal(5, User.all.length)
    assert_equal("Newlast", User.find("1").last_name)
  end

  def test_update_class_only_error_column
    assert_equal(5, User.all.length)
    updateuser = {id: "1", name: "Newlast"}
    user = User.update(updateuser)
    assert_equal(false, user)
    assert_equal(5, User.all.length)
    assert_equal("SATOU", User.find("1").last_name)
  end

  def test_update_class_exist_error_column
    assert_equal(5, User.all.length)
    updateuser = {id: "1", name: "Newlast", first_name: "Newname"}
    user = User.update(updateuser)
    assert_equal(true, user)
    assert_equal(5, User.all.length)
    assert_equal("Newname", User.find("1").first_name)
  end

################################################################################

  def test_destroy_class
    assert_equal(5, User.all.length)
    assert_equal("1", User.find("1").to_s)
    user = User.destroy("1")
    assert_equal(true, user)
    assert_equal(4, User.all.length)
    assert_nil(User.find("1"))
  end

  def test_destroy_no_record
    assert_equal(5, User.all.length)
    user = User.destroy("6")
    assert_equal(true, user)
    assert_equal(5, User.all.length)
  end

################################################################################

  def test_initialize
    newuser = {id: "6", last_name: "NewUser"}
    user = User.new(newuser)
    newcustomer = {id: "6", last_name: "NewCustomer"}
    customer = Customer.new(newcustomer)
    assert_equal("6", user.id)
    assert_equal("NewUser", user.last_name)
    assert_equal("6", customer.id)
    assert_equal("NewCustomer", customer.last_name)
  end

################################################################################

  def test_save_create
    assert_equal(5, User.all.length)
    assert_nil(User.find("6"))
    newuser = {id: "6", last_name: "Newlast", first_name: "Newname", gender: "1", dob: "19870601"}
    user = User.new(newuser)
    result = user.save
    assert_equal(true, result)
    assert_equal(6, User.all.length)
    user = User.find("6")
    assert_equal("6"       ,user.to_s)
    assert_equal("Newlast" ,user.last_name)
    assert_equal("Newname" ,user.first_name)
    assert_equal("1"       ,user.gender)
    assert_equal("19870601",user.dob)
  end

  def test_save_update
    assert_equal(5, User.all.length)
    updateuser = {id: "1", last_name: "Newlast"}
    user = User.new(updateuser)
    result = user.save
    assert_equal(true, result)
    assert_equal(5, User.all.length)
    assert_equal("Newlast", User.find("1").last_name)
  end

  def test_save_no_id
    assert_equal(5, User.all.length)
    newuser = {last_name: "Newlast", first_name: "Newname", gender: "1", dob: "19870601"}
    user = User.new(newuser)
    result = user.save
    assert_equal(true, result)
    assert_equal(6, User.all.length)
    assert_equal("[, 1, 2, 3, 4, 5]", User.all.to_s)
  end

  def test_save_no_data
    assert_equal(5, User.all.length)
    user = User.new
    result = user.save
    assert_equal(false, result)
    assert_equal(5, User.all.length)
  end

################################################################################

  def test_new_record
    newuser = {id: "1", last_name: "Newlast"}
    user = User.new(newuser)
    assert_equal(false, user.new_record?)
  end

  def test_new_record_exist_record
    newuser = {id: "6", last_name: "Newlast"}
    user = User.new(newuser)
    assert_equal(true, user.new_record?)
  end

################################################################################

  def test_update_attributes
    assert_equal(5, User.all.length)
    updateuser = {id: "1", last_name: "Newlast"}
    user = User.new(updateuser)
    result = user.update_attributes
    assert_equal(true, result)
    assert_equal(5, User.all.length)
    assert_equal("Newlast", User.find("1").last_name)
  end

  def test_update_class_only_error_column
    assert_equal(5, User.all.length)
    updateuser = {id: "1", name: "Newlast"}
    user = User.new(updateuser)
    result = user.update_attributes
    assert_equal(false, result)
    assert_equal(5, User.all.length)
    assert_equal("SATOU", User.find("1").last_name)
  end

  def test_update_attributes_exist_error_column
    assert_equal(5, User.all.length)
    updateuser = {id: "1", name: "Newlast", first_name: "Newname"}
    user = User.new(updateuser)
    result = user.update_attributes
    assert_equal(true, result)
    assert_equal(5, User.all.length)
    assert_equal("Newname", User.find("1").first_name)
  end

################################################################################

  def test_update_attribute
    assert_equal(5, User.all.length)
    user = User.find("1")
    result = user.update_attribute("last_name", "Newlast")
    assert_equal(true, result)
    assert_equal(5, User.all.length)
    assert_equal("Newlast", User.find("1").last_name)
  end

  def test_update_attribute_error
    assert_equal(5, User.all.length)
    user = User.find("1")
    result = user.update_attribute("name", "Newlast")
    assert_equal(false, result)
    assert_equal(5, User.all.length)
  end

################################################################################

  def test_destroy
    assert_equal(5, User.all.length)
    assert_equal("1", User.find("1").to_s)
    user = User.find("1")
    result = user.destroy
    assert_equal(true, result)
    assert_equal(4, User.all.length)
    assert_nil(User.find("1"))
  end

  def test_destroy_no_record
    assert_equal(5, User.all.length)
    newuser = {id: "6", last_name: "Newlast"}
    user = User.new(newuser)
    result = user.destroy
    assert_equal(true, result)
    assert_equal(5, User.all.length)
  end

################################################################################
end

