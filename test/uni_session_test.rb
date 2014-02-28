#!/usr/local/bin/ruby
#encoding: utf-8

require 'test_helper'

class UniSessionTest < MiniTest::Unit::TestCase

  def setup
    @session = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    create_table_read_test
    create_data_read_test
    create_table_readnext_test
    create_data_readnext_test
    create_table_bp
    copy_files
    create_subroutine
    create_basic_program
  end

  def teardown
    @session.execute('DELETE.FILE READ_TEST')
    @session.execute('DELETE.FILE READNEXT_TEST')
    @session.execute('DELETE.FILE BP')
    @session.execute('DELETE.FILE BP.O')
    UniObjects::quitall
  rescue
    session = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    session.execute('DELETE.FILE READ_TEST')
    session.execute('DELETE.FILE READNEXT_TEST')
    session.execute('DELETE.FILE BP')
    session.execute('DELETE.FILE BP.O')
    UniObjects::quitall
  end

################################################################################

  # UniSession.open(->UniFile.open)
  # ファイルをオープンする

  # ブロック指定なし
  def test_openfile_noblock
    file_noblock = @session.open('READ_TEST')
    assert_instance_of(UniObjects::UniFile, file_noblock)
  end

  # ブロック指定ありの場合
  def test_openfile_block
    @session.open('READ_TEST') do |file_block|
      assert_instance_of(UniObjects::UniFile, file_block)
    end
  end

  def test_openfile_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 14002] The file exists."){
      @session.open('NO_FILE')
    }
  end

  # UniSession.opendict(->UniDictionary.open)
  # ディクショナリファイルをオープンする

  # ブロック指定なし
  def test_opendict_noblock
    dict1 = @session.opendict('READ_TEST')
    assert_instance_of(UniObjects::UniDictionary, dict1)
  end

  # ブロック指定あり
  def test_opendict_block
    @session.opendict('READ_TEST') do |dict2|
      assert_instance_of(UniObjects::UniDictionary, dict2)
    end
  end

  def test_opendict_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 14002] The dict file exists."){
      @session.opendict('NO_FILE')
    }
  end

################################################################################

  # UniSession.quit
  # セッションを終了する
  # --- UniSession.execute を使用

  def test_quit
    # UniSession.executeが実行できることを確認する
    @session.execute('SELECT TEST_READ BY @ID')

    # セッションを終了する
    @session.quit

    # UniSession.executeがエラーになることを確認する
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.execute('SELECT TEST_READ BY @ID')
    }
  end

################################################################################

  # UniSession.readnext
  # 現在のアクティブな選択リストからレコードIDを返す
  # --- UniSession.execute を使用

  def test_readnext_no_select_list_num
    # select_list_num指定なし
    @session.execute('SELECT READ_TEST BY @ID')
    id_list=[]
    loop{
      id=@session.readnext
      break if id == ""
      id_list << id
    }
    assert_equal("1,2,3", id_list.join(','))
  end

  def test_readnext_select_list_num
    # select_list_numを指定
    # 0は揮発性が高いため、0を指定した後に別コマンドを実行すると上書きされる可能性がある
    @session.execute('SELECT READNEXT_TEST BY @ID TO 1')
    @session.execute('SELECT READ_TEST BY @ID TO 2')
    id_list=[]
    loop{
      id=@session.readnext(2)
      break if id == ""
      id_list << id
    }
    loop{
      id=@session.readnext(1)
      break if id == ""
      id_list << id
    }
    assert_equal("1,2,3,0", id_list.join(','))
  end

  def test_readnext_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 33211] Good select list number."){
      @session.readnext(11)
    }
  end

################################################################################

  # UniSession.set_locale
  # サーバー上でロケールをセットする
  # UniSession.get_locale
  # サーバーが使用しているロケールの名前を検索する

  def test_set_get_locale
    assert("JP-JAPANESE", @session.get_locale(UniObjects::IK_LC_ALL     ))
    assert("OFF"        , @session.get_locale(UniObjects::IK_LC_TIME    ))
    assert("OFF"        , @session.get_locale(UniObjects::IK_LC_NUMERIC ))
    assert("OFF"        , @session.get_locale(UniObjects::IK_LC_MONETARY))
    assert("OFF"        , @session.get_locale(UniObjects::IK_LC_CTYPE   ))
    assert("OFF"        , @session.get_locale(UniObjects::IK_LC_COLLATE ))
    @session.set_locale(UniObjects::IK_LC_ALL     ,'DEFAULT'    )
    @session.set_locale(UniObjects::IK_LC_TIME    ,'JP-JAPANESE')
    @session.set_locale(UniObjects::IK_LC_NUMERIC ,'DEFAULT'    )
    @session.set_locale(UniObjects::IK_LC_MONETARY,'JP-JAPANESE')
    @session.set_locale(UniObjects::IK_LC_CTYPE   ,'DEFAULT'    )
    @session.set_locale(UniObjects::IK_LC_COLLATE ,'JP-JAPANESE')
    assert("DEFAULT"    , @session.get_locale(UniObjects::IK_LC_ALL     ))
    assert("JP-JAPANESE", @session.get_locale(UniObjects::IK_LC_TIME    ))
    assert("DEFAULT"    , @session.get_locale(UniObjects::IK_LC_NUMERIC ))
    assert("JP-JAPANESE", @session.get_locale(UniObjects::IK_LC_MONETARY))
    assert("DEFAULT"    , @session.get_locale(UniObjects::IK_LC_CTYPE   ))
    assert("JP-JAPANESE", @session.get_locale(UniObjects::IK_LC_COLLATE ))
  end

  def test_set_locale_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 14012] Memory available."){
      @session.set_locale(UniObjects::IK_LC_ALL,'')
    }
  end

  def test_get_locale_uni_error
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.get_locale(UniObjects::IK_LC_ALL)
    }
  end

################################################################################

  # UniSession.set_map
  # サーバー間のデータ転送のMAPをセットする
  # UniSession.get_map
  # サーバーが現在使用しているMAPの名前を検索する

  def test_set_get_map
    assert_equal("UTF8",    @session.get_map)
    @session.set_map('DEFAULT')
    assert_equal("UTF8",    @session.get_map)
    @session.set_map('NONE')
    assert_equal("NONE",    @session.get_map)
    @session.set_map('MS932')
    assert_equal("MS932",   @session.get_map)
    @session.set_map('ASCII')
    assert_equal("ASCII",   @session.get_map)
    @session.set_map('JIS-EUC')
    assert_equal("JIS-EUC", @session.get_map)
    @session.set_map('UTF8')
    assert_equal("UTF8",    @session.get_map)
  end

  def test_set_map_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 14012] Memory available."){
      @session.set_map('')
    }
  end

  def test_get_map_uni_error
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.get_map
    }
  end

################################################################################

  # UniSession.get_mark_value
  # 以下が確認できているのでOK
  #   UniSession.open()が正常に動いていること
  #   @session.AM等が正常に使用できていること

################################################################################

  # UniSession.clear_data
  # UniSession.dataによってロードされたデータをフラッシュする
  # --- UniSession.data    を使用
  # --- UniSession.execute を使用

  def test_clear_data
    # queueに入力
    @session.data('TEST123')
    @session.data('READ_TEST')

    # queueの中を全て削除
    @session.clear_data

    # queueの中が空になったためエラーになることを確認
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39119] Not waiting for terminal input."){
      @session.execute('FILE.STAT')
    }
  end

  def test_clear_data_uni_error
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.clear_data
    }
  end

################################################################################

  # UniSession.data
  # データを要求しているサーバへ文字列を返す
  # --- UniSession.execute を使用

  def test_data
    # queueに入力
    @session.data('TEST123')
    @session.data('READ_TEST')

    # queueから取り出す順番が合っていることを確認
    # 処理内容が正しいことを確認
    str=@session.execute('FILE.STAT')
    assert_equal("File name        =  TEST123\r\nMust specify file name.\r\n", str) 
    str=@session.execute('FILE.STAT')
    assert_equal("READ_TEST", str[20,9])

    # queueの中が空になったためエラーになることを確認
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39119] Not waiting for terminal input."){
      @session.execute('FILE.STAT')
    }
  end

  def test_data_uni_error
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.data('READ_TEST')
    }
  end

################################################################################

  # UniSession.execute
  # サーバ・データベース・コマンドを実行する
  # UniSession.executecontinue
  # UniSession.executeでIE_BTSが発生したらコマンド実行を再開する

  def test_execute
    # IE_BTSが発生しない場合
    str=@session.execute('RUN BP WITHINTEST')
    # 結果内容を確認
    assert_equal("Hello,SAMPLE1", str[0,13])

    # 結果がnilであることを確認
    strcon=@session.executecontinue
    assert_nil(strcon)
  end

  def test_execute_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39119] Not waiting for terminal input."){
      @session.execute('CREATE.FILE')
    }
  end

  def test_executecontinue
    # IE_BTSが発生する場合
    str=@session.execute('RUN BP OVERTEST')

    # 結果がnilでないことを確認
    strcon=@session.executecontinue
    assert(strcon)

    # 結果内容を確認
    strcon=@session.executecontinue
    assert_equal("SAMPLE3", strcon[0,7])

    # 結果がnilであることを確認
    strcon=@session.executecontinue
    assert_nil(strcon)
  end

  def test_executecontinue_uni_error
    str=@session.execute('RUN BP OVERTEST')
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      strcon=@session.executecontinue
    }
  end

################################################################################

  # UniSession.itype
  # I記述子の評価の結果から値を返す

  def test_itype
    # ファイルを指定する場合(UniSession)
    assert_equal("3000:1000", @session.itype('READ_TEST','3','KINGAKU').gsub(@session.VM,":"), "ng!")
  end

  def test_itype_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30111] It is an I-type."){
      @session.itype('READ_TEST', '3','TANTO')
    }
  end

################################################################################

  # UniSession.subcall
  # カタログ化されたサブルーチンを呼び出す

  def test_subcall1
    # 引数 1個のサブルーチンSUBCALL1
    # inout = inout + " subcall " + inout
    inout1="test1"
    inout1=@session.subcall1('SUBCALL1', 1, inout1)
    assert_equal("test1 subcall test1", inout1)
  end

  def test_subcall1_uni_error
    inout1="test1"
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.subcall1('SUBCALL1', 1, inout1)
    }
  end

  def test_subcall2
    # 引数 2個のサブルーチンSUBCALL2
    # inout = inout + " subcall " + inout
    inout1="test2-1"
    inout2="test2-2"
    inout1, inout2=@session.subcall2('SUBCALL2', 2, inout1, inout2)
    assert_equal("test2-1 subcall test2-1", inout1)
    assert_equal("test2-2 subcall test2-2", inout2)
  end

  def test_subcall2_uni_error
    inout1="test2-1"
    inout2="test2-2"
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.subcall2('SUBCALL2', 2, inout1, inout2)
    }
  end

  def test_subcall3
    # 引数 3個のサブルーチンSUBCALL3
    # inout = inout + " subcall " + inout
    inout1="test3-1"
    inout2="test3-2"
    inout3="test3-3"
    inout1, inout2, inout3=@session.subcall3('SUBCALL3', 3, inout1, inout2, inout3)
    assert_equal("test3-1 subcall test3-1", inout1)
    assert_equal("test3-2 subcall test3-2", inout2)
    assert_equal("test3-3 subcall test3-3", inout3)
  end

  def test_subcall3_uni_error
    inout1="test3-1"
    inout2="test3-2"
    inout3="test3-3"
    UniObjects::quitall
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39120] The session open."){
      @session.subcall3('SUBCALL3', 3, inout1, inout2, inout3)
    }
  end

################################################################################
end

