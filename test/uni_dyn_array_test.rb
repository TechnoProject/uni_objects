#!/usr/local/bin/ruby
#encoding: utf-8

require 'test_helper'

class UniDynArrayTest < MiniTest::Unit::TestCase

  def setup
    s1 = "AAA\xEF\xA3\xBEBB1\xEF\xA3\xBDB21\xEF\xA3\xBCB22\xEF\xA3\xBCB23\xEF\xA3\xBDBB3\xEF\xA3\xBECCC"
    s2 = "9\xEF\xA3\xBE88\xEF\xA3\xBD777\xEF\xA3\xBC6666\xEF\xA3\xBC55555\xEF\xA3\xBD444444\xEF\xA3\xBE3333333"
    @session = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    @dyn_array = UniObjects::UniDynArray.new(s1)
    @dyn_array_locate = UniObjects::UniDynArray.new(s2)
    @longstr = "a" * 1000
  end

  def teardown
    UniObjects::quitall
  end

################################################################################

  # UniDynArray.alpha
  # 文字列がアルファベットか判断する

  def test_alpha_alphabet_only
    # アルファベットのみの場合
    assert_equal(true, UniObjects::UniDynArray.alpha("TEST"))
  end

  def test_alpha_alphabet_number
    # アルファベット以外を含む場合
    assert_equal(false, UniObjects::UniDynArray.alpha("Taa222T"))
    assert_equal(false, UniObjects::UniDynArray.alpha("123&"))
  end

  def test_alpha_uni_error
  end

################################################################################

  # UniDynArray.extract
  # データを抽出する

  def test_extract_field
    # 抽出するfieldのみ指定
    assert_equal("BB1:B21.B22.B23:BB3",
                  @dyn_array.extract(2).gsub(@session.AM,"|")
                                       .gsub(@session.VM,":")
                                       .gsub(@session.SM,"."))
  end

  def test_extract_value
    # 抽出するfield,valueを指定
    assert_equal("BB1" ,        @dyn_array.extract(2,1))
    assert_equal("B21.B22.B23", @dyn_array.extract(2,2).gsub(@session.SM,"."))
    assert_equal("BB3" ,        @dyn_array.extract(2,3))
  end

  def test_extract_subvalue
    # 抽出するfield,value,subvalueを指定
    assert_equal("B23", @dyn_array.extract(2,2,3))
  end

  def test_extract_no_data
    # 抽出する値がない場所を指定
    assert_equal("", @dyn_array.extract(4)    )
  end

  def test_extract_uni_error
  end

################################################################################
 
  # UniDynArray.insert
  # 指定したフィールド、値、サブ値を挿入する

  def test_insert_field
    # 挿入するfieldのみ指定
    @dyn_array.insert('str', 2)
    assert_equal("AAA|str|BB1:B21.B22.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_insert_value
    # 挿入するfield,valueを指定i
    @dyn_array.insert('str', 2, 2)
    assert_equal("AAA|BB1:str:B21.B22.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_insert_subvalue
    # 挿入するfield,value,subvalueを指定
    @dyn_array.insert('str', 2, 2, 2)
    assert_equal("AAA|BB1:B21.str.B22.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_insert_no_data
    # 挿入する場所に値がない(離れている場所)を指定
    @dyn_array.insert('str', 5)
    assert_equal("AAA|BB1:B21.B22.B23:BB3|CCC||str",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_insert_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22002] Buffer too not small."){
      @dyn_array.insert(@longstr, 5)
    }
  end

################################################################################

  # UniDynArray.locate
  # 文字列のダイナミックアレイを検索する

  def test_locate_str_only
    # strのみを指定
=begin
    ss="AAA\xEF\xA3\xBEBBB\xEF\xA3\xBECCC"
    dyn_array=UniObjects::UniDynArray.new(ss)
    puts dyn_array.to_s.gsub(@session.IM,"|")
    puts dyn_array.locate("AAA",2)
=end
    assert_equal(1, @dyn_array_locate.locate("9"))
  end

  def test_locate_field
    # str, field を指定
    assert_equal(1, @dyn_array_locate.locate("9",1))
    assert_equal(1, @dyn_array_locate.locate("9",0))
    assert_equal(1, @dyn_array_locate.locate("9",-1))
  end

  def test_locate_value
    # str, field, value を指定
    assert_equal(1, @dyn_array_locate.locate("88",2,1))
  end

  def test_locate_subvalue
    # str, field, subvalue を指定、order指定なし
    assert_equal(1  , @dyn_array_locate.locate("777"  ,2,2,1))
    assert_equal(nil, @dyn_array_locate.locate("6666" ,2,2,1))
    assert_equal(nil, @dyn_array_locate.locate("55555",2,2,1))
  end

  def test_locate_order_al
    # order="AL"を指定
    assert_equal(1  , @dyn_array_locate.locate("777"  ,2,2,1,"AL"))
    assert_equal(nil, @dyn_array_locate.locate("6666" ,2,2,1,"AL"))
    assert_equal(nil, @dyn_array_locate.locate("55555",2,2,1,"AL"))
  end

  def test_locate_order_ar
    # order="AR"を指定
    assert_equal(1  , @dyn_array_locate.locate("777"  ,2,2,1,"AR"))
    assert_equal(2  , @dyn_array_locate.locate("6666" ,2,2,1,"AR"))
    assert_equal(3  , @dyn_array_locate.locate("55555",2,2,1,"AR"))
  end

  def test_locate_order_d
    # order="D"を指定
    assert_equal(1  , @dyn_array_locate.locate("777"  ,2,2,1,"D"))
    assert_equal(2  , @dyn_array_locate.locate("6666" ,2,2,1,"D"))
    assert_equal(3  , @dyn_array_locate.locate("55555",2,2,1,"D"))
  end

  def test_locate_order_dr
    # order="DR"を指定
    assert_equal(1  , @dyn_array_locate.locate("777"  ,2,2,1,"DR"))
    assert_equal(nil, @dyn_array_locate.locate("6666" ,2,2,1,"DR"))
    assert_equal(nil, @dyn_array_locate.locate("55555",2,2,1,"DR"))
  end

  def test_locate_uni_error
  end

################################################################################

  # UniDynArray.remove
  # ダイナミックアレイから連続した部分文字列を削除する
  # def test_remove
  #   @dyn_array.each do |n|
  #     puts n
  #   end
  # end

################################################################################

  # UniDynArray.replace
  # ダイナミックアレイ内のデータを置換する

  def test_replace_str_only
    # 置換する文字列のみ指定
    @dyn_array.replace('str')
    assert_equal("str|AAA|BB1:B21.B22.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_replace_field
    # 挿入するfieldを指定
    @dyn_array.replace('str', 2)
    assert_equal("AAA|str|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_replace_value
    # 挿入するfield,valueを指定
    @dyn_array.replace('str', 2, 2)
    assert_equal("AAA|BB1:str:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_replace_subvalue
    # 挿入するfield,value,subvalueを指定
    @dyn_array.replace('str', 2, 2, 2)
    assert_equal("AAA|BB1:B21.str.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_replace_no_data
    # 挿入する場所に値がない(離れている場所)を指定
    @dyn_array.replace('str', 5)
    assert_equal("AAA|BB1:B21.B22.B23:BB3|CCC||str",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_replace_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22002] Buffer too not small."){
      @dyn_array.replace(@longstr, 6)
    }
  end

################################################################################

  # UniDynArray.del
  # データを削除する

  def test_del_field
    # 削除するfieldのみ指定
    @dyn_array.del(2)
    assert_equal("AAA|CCC", 
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_del_value
    # 削除するfield,valueを指定
    @dyn_array.del(2,1)
    assert_equal("AAA|B21.B22.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_del_subvalue
    # 削除するfield,value,subvalueを指定
    @dyn_array.del(2,2,3)
    assert_equal("AAA|BB1:B21.B22:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_del_no_data
    # 削除する値がない場所を指定
    @dyn_array.del(4)
    assert_equal("AAA|BB1:B21.B22.B23:BB3|CCC",
                  @dyn_array.to_s.gsub(@session.AM,"|")
                                 .gsub(@session.VM,":")
                                 .gsub(@session.SM,"."))
  end

  def test_del_uni_error
  end

################################################################################
end

