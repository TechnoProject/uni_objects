#ifndef UNISESSION_HPP
#define UNISESSION_HPP

using namespace std;

//! Accessing a server(サーバーへのアクセス)
class UniSession {

  string m_server;
  string m_userid;
  string m_password; 
  string m_account;
  string m_subkey;

  long  m_readnext_code;
  long  m_session_id;

  char *buffer;
  long max_buffer_size;
  long status_code;

public:

  string  IM,FM,AM,VM,SM,TM,SQLNULL;

public:

  //! コンストラクタ
  UniSession(char *server,char *userid, char *password, char *account, char *subkey="");

  //! デストラクタ
  virtual ~UniSession();
  
  //! データベース・サーバ上でセッションを開始する
  //! 
  //! @param なし
  //! 
  //! @return 
  //!      　　ブロック指定あり -> Qnil
  //!  <br>　　ブロック指定なし -> Session
  //! 
  VALUE open();
    
  //! ファイルをオープンする
  //! 
  //! @param filename  ファイル名
  //! 
  //! @return UniFile.open
  //! 
  VALUE open(char* filename); 
  
  //! ディクショナリファイルをオープンする
  //! 
  //! @param filename  ファイル名
  //! 
  //! @return UniDictionary.open
  //! 
  VALUE opendict(char* filename); 
    
  //! サーバ・データベース・コマンドを実行する
  //! 
  //! @param command 実行するコマンド
  //! 
  //! @return 実行結果
  //! 
  VALUE execute(char* command); 

  //! UniSession.executeでIE_BTSが発生したらコマンド実行を再開する
  //! 
  //! @param なし
  //! 
  //! @return 
  //!      　　バッファが小さい -> rb_str_new
  //!  <br>　　バッファが小さくない -> Qnil
  //! 
  VALUE executecontinue(); 

  //! データを要求しているサーバへ文字列を渡す
  //! 
  //! @param data ロードするデータ
  //! 
  //! @return なし
  //! 
  void data(VALUE data); 

  //! UniSession.dataによってロードされたデータをフラッシュする
  //! 
  //! @param なし
  //! 
  //! @return なし
  //! 
  void clear_data(); 

  //! セッションを終了する
  //! 
  //! @param なし
  //! 
  //! @return なし
  //! 
  void quit();

  //! I記述子の評価の結果から値を返す
  //! 
  //! @param filename  ファイル名
  //! @param record_id レコードID
  //! @param itype_id  I記述子
  //! 
  //! @return 指定したI記述子の値
  //! 
  VALUE itype(char* filename, char* record_id, char* itype_id);

  //! カタログ化されたサブルーチンを呼び出す(引数1個)
  //! 
  //! @param subname 呼び出すサブルーチン名
  //! @param argnum  渡す引数の数
  //! @param arg1    引数
  //! 
  //! @return なし
  //! 
  void subcall1(char* subname, long argnum, std::string & arg1);
  
  //! カタログ化されたサブルーチンを呼び出す(引数2個)
  //! 
  //! @param subname 呼び出すサブルーチン名
  //! @param argnum  渡す引数の数
  //! @param arg1    引数
  //! @param arg2    引数
  //! 
  //! @return なし
  //! 
  void subcall2(char* subname, long argnum, std::string & arg1, std::string & arg2);

  //! カタログ化されたサブルーチンを呼び出す(引数3個)
  //! 
  //! @param subname 呼び出すサブルーチン名
  //! @param argnum  渡す引数の数
  //! @param arg1    引数
  //! @param arg2    引数
  //! @param arg3    引数
  //! 
  //! @return なし
  //! 
  void subcall3(char* subname, long argnum, std::string & arg1, std::string & arg2, std::string & arg3);

  //! 現在のアクティブな選択リストからレコードIDを返す
  //! 
  //! @param select_list_num=0
  //! 
  //! @return レコードID
  //! 
  VALUE readnext(long select_list_num=0);

  //! 要素を順番に取り出してブロックに渡す
  //! 
  //! @param select_list_num
  //! 
  //! @return
  //!      　　ブロック指定あり -> レコードID
  //!  <br>　　ブロック指定なし -> Qnil 
  //! 
  VALUE each(int select_list_num=0);

  //! サーバー間のデータ転送のMAPをセットする
  //! 
  //! @param map_string 現在のサーバロケールのMAP名
  //! 
  //! @return なし
  //! 
  void set_map(VALUE map_string);

  //! サーバーが現在使用しているMAPの名前を検索する
  //! 
  //! @param なし
  //! 
  //! @return MAP名
  //! 
  VALUE get_map();

  //! サーバー上でロケールをセットする
  //! 
  //! @param key セットしたいロケール情報
  //!  <br>　　IK_LC_ALL      = All categories
  //!  <br>　　IK_LC_TIME     = Time category
  //!  <br>　　IK_LC_NUMERIC  = Numeric category
  //!  <br>　　IK_LC_MONETARY = Monetary category
  //!  <br>　　IK_LC_CTYPE    = Ctype category
  //!  <br>　　IK_LC_COLLATE  = Collate category
  //! @param locale_string 要求されたカテゴリーのためにセットするロケール
  //! 
  //! @return なし
  //! 
  void set_locale(long key, VALUE locale_string); 

  //! サーバーが使用しているロケールの名前を検索する
  //! 
  //! @param key 取得するロケール情報
  //!  <br>　　IK_LC_ALL = All categories
  //!  <br>　　IK_LC_TIME = Time category
  //!  <br>　　IK_LC_NUMERIC = Numeric category
  //!  <br>　　IK_LC_MONETARY = Monetary category
  //!  <br>　　IK_LC_CTYPE = Ctype category
  //!  <br>　　IK_LC_COLLATE = Collate category
  //! 
  //! @return 現在のサーバのロケールの名前
  //! 
  VALUE get_locale(long key);

protected:

  //! サーバー上で現在の文字セットの中で使用されるUniVerseシステム・デリミッターの文字値を検索する
  //! 
  //! @param key システム区切り文字のタイプ
  //!  <br>　　IK_IM = Item mark
  //!  <br>　　IK_FM = Field mark
  //!  <br>　　IK_VM = Value mark
  //!  <br>　　IK_SM = Subvalue mark
  //!  <br>　　IK_TM = Text mark
  //!  <br>　　IK_NULL = The null value
  //! 
  //! @return システムの区切り文字の文字値
  //! 
  string get_mark_value(long key);

private:

  //! 以前に割り当てられたメモリを解放する
  //! 
  //! @param ptr 解放するメモリのポインタ
  //! 
  //! @return なし
  //! 
  void free(void* ptr);

  //! サブルーチンの引数を生成
  //! 
  //! @param arg1 引数
  //! 
  //! @return サブルーチンの引数
  //!  
  ICSTRING setArgs(std::string arg1);

};

#endif
