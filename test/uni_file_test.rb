#!/usr/local/bin/ruby
#encoding: utf-8

require 'test_helper'

class UniFileTest < MiniTest::Unit::TestCase

  def setup
    @session = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    create_table_clear_test
    create_table_write_test
    create_data_write_test
    create_table_read_test
    create_data_read_test
  end

  def teardown
    @session.execute('DELETE.FILE CLEAR_TEST')
    @session.execute('DELETE.FILE WRITE_TEST')
    @session.execute('DELETE.FILE READ_TEST')
    UniObjects::quitall
  end

################################################################################

  # UniFile.close
  # UniFile.openで開いたファイルを閉じる

  def test_close
    @file_read.close
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22005] File close was successful."){
      @file_read.close
    }
  end

################################################################################

  # UniFile.read
  # DBファイルからレコードを読み込む
  # --- UniSession.execute を使用

  def test_read_no_lock
    # ロック指定なし
    @file_read.read(3)
    assert_equal("WATANABE|2011/12/12|scissors:pencil|300:50|10:20", 
                 @file_read.read(3).gsub(@session.AM,"|")
                                       .gsub(@session.VM,":")
                                       .gsub(@session.SM,"."))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_read_lock_ik_read
    # lock=IK_READを指定
    @file_read.read(3, UniObjects::IK_READ)
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_read_lock_ik_readl
    # lock=IK_READLを指定
    @file_read.read(3, UniObjects::IK_READL)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_read_lock_ik_readu
    # lock=IK_READUを指定
    @file_read.read(3, UniObjects::IK_READU)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_read_lock_ik_readlw
    # lock=IK_READLWを指定
    @file_read.read(3, UniObjects::IK_READLW)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_read_lock_ik_readuw
    # lock=IK_READUWを指定
    @file_read.read(3, UniObjects::IK_READUW)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_read_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30001] A record exists."){
      @file_read.read(4)
    }
  end

################################################################################

  # UniFile.readfield
  # --- UniSession.execute を使用

  def test_readfield_no_lock
    assert_equal("SATOU", @file_read.readfield("1", 1))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_readfield_lock_ik_read
    assert_equal("SATOU", @file_read.readfield("1", 1, UniObjects::IK_READ))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_readfield_lock_ik_readl
    @file_read.readfield("1", 1, UniObjects::IK_READL)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_readfield_lock_ik_readu
    @file_read.readfield("1", 1, UniObjects::IK_READU)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_readfield_lock_ik_readlw
    @file_read.readfield("1", 1, UniObjects::IK_READLW)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_readfield_lock_ik_readuw
    @file_read.readfield("1", 1, UniObjects::IK_READUW)
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_readfield_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30001] A recordfield exists."){
      @file_read.readfield("4", 1)
    }
  end

################################################################################

  # UniFile.write
  # オープン・サーバ・データベース・ファイル内のレコードに新しい値を書き込む
  # --- UniSession.execute を使用
  # --- UniFile.read       を使用

  def test_write_no_lock
    # ロック指定なし
    @file_write.read(1, UniObjects::IK_READU)
    @file_write.write(1, "scissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
    assert_equal("scissors:pencil|300:50|10:20", 
                 @file_write.read(1).gsub(@session.AM,"|")
                                    .gsub(@session.VM,":"))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_write_lock_ik_write
    # lock=IK_WRITEを指定
    @file_write.read(2, UniObjects::IK_READU)
    @file_write.write(2, "write_test2", UniObjects::IK_WRITE)
    assert_equal("write_test2", @file_write.read(2))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_write_lock_ik_writew
    # lock=IK_WRITEWを指定
    @file_write.read(3, UniObjects::IK_READU)
    @file_write.write(3, "write_test3", UniObjects::IK_WRITEW)
    assert_equal("write_test3", @file_write.read(3))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_write_lock_ik_writeu
    # lock=IK_WRITEUを指定
    @file_write.read(4, UniObjects::IK_READU)
    @file_write.write(4, "write_test4", UniObjects::IK_WRITEU)
    assert_equal("write_test4", @file_write.read(4))
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_write_uni_error
    @file_write.close
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22005] Write record was successful."){
      @file_write.write(5, "write_test5")
    }
  end

################################################################################

  # UniFile.writefield
  # オープン・サーバ・データベース・ファイル内のレコードのフィールドに新しい値を書き込む
  # --- UniSession.execute を使用
  # --- UniFile.readfield  を使用

  def test_writefield_no_lock
    # ロック指定なし
    @file_write.readfield("1", 1, UniObjects::IK_READU)
    @file_write.writefield("1", 1, "writefield_test\xEF\xA3\xBDwritev")
    assert_equal("writefield_test:writev", @file_write.readfield("1", 1).gsub(@session.VM,":"))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_writefield_lock_ik_write
    # lock=IK_WRITEを指定
    @file_write.readfield("2", 2, UniObjects::IK_READU)
    @file_write.writefield("2", 2, "writefield_test2", UniObjects::IK_WRITE)
    assert_equal("writefield_test2", @file_write.readfield("2", 2))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_writefield_lock_ik_writew
    # lock=IK_WRITEWを指定
    @file_write.readfield("3", 3, UniObjects::IK_READU)
    @file_write.writefield("3", 3, "writefield_test3", UniObjects::IK_WRITEW)
    assert_equal("writefield_test3", @file_write.readfield("3", 3))
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end

  def test_writefield_lock_ik_writeu
    # lock=IK_WRITEUを指定
    @file_write.readfield("4", 4, UniObjects::IK_READU)
    @file_write.writefield("4", 4, "writefield_test4", UniObjects::IK_WRITEU)
    assert_equal("writefield_test4", @file_write.readfield("4", 4))
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_writefield_uni_error
    @file_write.close
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22005] Write field was successful."){
      @file_write.writefield("5", 5, "writefield_test5")
    }
  end

################################################################################

  # UniFile.release
  # 指定したレコードのロックを解放する

  def test_release_all_record
    @file_read.read("1", UniObjects::IK_READU)
    @file_read.read("2", UniObjects::IK_READU)
    @file_read.release
    assert_equal("No locks or semaphores active", @session.execute('LIST.READU')[2,29])
  end
  
  def test_release_1_record
    @file_read.read("1", UniObjects::IK_READU)
    @file_read.read("2", UniObjects::IK_READU)
    @file_read.release("1")
    assert_equal("Active Record Locks", @session.execute('LIST.READU')[2,19])
  end

  def test_release_uni_error
    @file_read.close
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22005] Record release was successful."){
      @file_read.release
    }
  end

################################################################################

  # UniFile.deleterecord
  # レコードを削除する

  def test_deleterecord
    @file_write.write("10", "deleterecordtest10")
    @file_write.read("10")
    @file_write.deleterecord("10")
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30001] Record still exists."){
      @file_write.deleterecord("10")
    }
  end

################################################################################

  # UniFile.clear
  # オープン・サーバ・データベース・ファイルから全てのレコードを削除する
  # --- UniFile.read  を使用
  # --- UniFile.write を使用

  def test_clear
    # ファイルにデータを作成する
    @file_clear.write(1,"testtest1")
    @file_clear.write(2,"testtest2")
    # レコードを読み込んでもエラーにならないことを確認する
    @file_clear.read(1)
    @file_clear.read(2)
    
    # ファイルからレコードを削除する
    @file_clear.clear
    # レコードが存在しないためエラーになることを確認する
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30001] Read record was successful."){
      @file_clear.read(1)
    }
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30001] Read record was successful."){
      @file_clear.read(2)
    }
  end

  def test_clear_uni_error
    @file_clear.close
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 22005] Clear file was successful."){
      @file_clear.clear
    }
  end

################################################################################

  # UniFile.itype
  # I記述子の評価の結果から値を返す

  def test_itype
    # ファイルを指定しない場合(UniFile)
    assert_equal("3000:1000", @file_read.itype('3','KINGAKU').gsub(@session.VM,":"))
  end

  def test_itype_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 30111] It is an I-type."){
      @file_read.itype('3','TANTO')
    }
  end

################################################################################
end

