#!/usr/local/bin/ruby
#encoding: utf-8

require 'test_helper'

class UniObjectTest < MiniTest::Unit::TestCase

  def setup
    @session = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
  end

  def teardown
    UniObjects::quitall
  end

################################################################################

  # UniObject.open(->UniSession.open)
  # データベース・サーバ上でセッションを開始する

  # ブロック指定なしの場合
  def test_opensession_noblock
    assert_instance_of(UniObjects::UniSession, @session)
  end

  # ブロック指定ありの場合
  def test_opensession_block
    UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account']) do |session1|
      assert_instance_of(UniObjects::UniSession, session1)
    end
  end

  def test_opensession_uni_error
    assert_raises(UniObjects::UniError, message="[assert_raises][Not 39125] It is a database account."){
      UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], '/noaccount')
    }
  end

################################################################################

  # UniObject.quitall
  # すべてのセッションを終了する
  # --- UniObjects::open を使用

  def test_quitall
    # 最初にリセットする
    UniObjects::quitall
    # 同時セッション数の上限まで接続する
    session1 = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    session2 = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])

    # 同時セッション数の上限を超えるとエラーになる
    assert_raises(UniObjects::UniError, message="assert_raises"){
      session3 = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    }

    # 全てのセッションを終了する
    UniObjects::quitall
    # 同時セッション数の上限まで接続できることを確認する
    session4 = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
    session5 = UniObjects::open(ENV['server'], ENV['userid'], ENV['passwd'], ENV['account'])
  end

################################################################################
end

