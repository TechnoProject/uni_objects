#ifndef INCLUDED_UNIFILE
#define INCLUDED_UNIFILE

using namespace std;

//! Reading and modifying sequential files(シーケンシャルファイルの読み込みと変更)
//  Managing database files(管理するデータベースファイル)
class UniFile {

protected:

  long file_id;
  long max_buffer_size;
  char* buffer;
  char* m_filename;

public:

  //! コンストラクタ
  UniFile();

  //! デストラクタ
  virtual ~UniFile();

  //! コピーコンストラクタ
  UniFile(const UniFile& x);

  //! データファイルをオープンする
  //! 
  //! @param filename  ファイル名
  //! 
  //! @return ブロック指定あり -> nil, ブロック指定なし -> File
  //! 
  VALUE open(char* filename);

  //! オープン・サーバ・データベース・ファイルから全てのレコードを削除する
  //! 
  //! @param なし
  //! 
  //! @return なし
  //! 
  void clear();

  //! UniFile.openで開いたファイルを閉じる
  //! 
  //! @param なし
  //! 
  //! @return なし
  //! 
  void close();

  //! オープン・サーバ・データベース・ファイルからレコードを読み込む
  //! 
  //! @param record_id レコードID
  //! @param lock      ロックの種類
  //!  <br>　　IK_READ   = ロックしない
  //!  <br>　　IK_READL  = 他ユーザがIK_READUロックをすることを防ぐ
  //!  <br>　　IK_READU  = 他ユーザが同レコードをロックをすることを防ぐ
  //!  <br>　　IK_READLW = 他ユーザがIK_READUロックをすることを防ぐ
  //!  <br>　　IK_READUW = 他ユーザが同レコードをロックをすることを防ぐ
  //! 
  //! @return 読み込まれたレコードの文字列
  //! 
  VALUE read(VALUE record_id,long lock=IK_READ);

  //! オープン・サーバ・データベース・ファイルからレコードのフィールドを読み込む
  //! 
  //! @param record_id     レコードID
  //! @param field_number  フィールドの数
  //! @param lock          ロックの種類
  //!  <br>　　IK_READ   = ロックしない
  //!  <br>　　IK_READL  = 他ユーザがIK_READUロックをすることを防ぐ
  //!  <br>　　IK_READU  = 他ユーザが同レコードをロックをすることを防ぐ
  //!  <br>　　IK_READLW = 他ユーザがIK_READUロックをすることを防ぐ
  //!  <br>　　IK_READUW = 他ユーザが同レコードをロックをすることを防ぐ
  //! 
  //! @return 読み込まれたフィールドの文字列
  //! 
  VALUE readfield(VALUE record_id, long field_number, long lock=IK_READ);

  //! オープン・サーバ・データベース・ファイル内のレコードに新しい値を書き込む
  //! 
  //! @param record_id レコードID
  //! @param record    レコード
  //! @param lock      ロックの種類
  //!  <br>　　IK_WRITE  = 目的のレコードのロックを解放する
  //!  <br>　　IK_WRITEW = 対象レコードに排他的な更新がある場合、ロックが解除されるまで一時停止する
  //!  <br>　　IK_WRITEU = 任意のロックが保持されるべきであることを指定する
  //! 
  //! @return なし
  //! 
  void write(VALUE record_id, VALUE record, long lock=IK_WRITE);

  //! オープン・サーバ・データベース・ファイル内のレコードのフィールドに新しい値を書き込む
  //! 
  //! @param record_id    レコードID
  //! @param field_number フィールドの数
  //! @param field        フィールド
  //! @param lock         ロックの種類
  //!  <br>　　IK_WRITE  = 目的のレコードのロックを解放する
  //!  <br>　　IK_WRITEW = 対象レコードに排他的な更新がある場合、ロックが解除されるまで一時停止する
  //!  <br>　　IK_WRITEU = 任意のロックが保持されるべきであることを指定する
  //! 
  //! @return なし
  //! 
  void writefield(VALUE record_id, long field_number, VALUE field, long lock=IK_WRITE);

  //! ファイル内のレコードのロックを解放する
  //! 
  //! @param record_id 解放するレコードID(指定なし:全レコードを解放する)
  //! 
  //! @return なし
  //! 
  void release(VALUE record_id=Qnil);

  //! データベースファイルからレコードを削除する
  //! 
  //! @param record_id 削除するレコードID
  //! @param lock      対象レコードにロックがかかっているときの動きを指定
  //!  <br>　　IK_DELETE  = 排他ロックがかかっている場合、エラーになる
  //!  <br>　　IK_DELETEW = 排他ロックがかかっている場合、ロックが解除されるまで一時停止する
  //!  <br>　　IK_DELETEU = 削除後の記録にユーザが保持しているすべてのロックを保持する
  //! 
  //! @return なし
  //! 
  void deleterecord(VALUE record_id, long lock=IK_DELETE);

  //! I記述子の評価の結果から値を返す
  //! 
  //! @param record_id レコードID
  //! @param itype_id  I記述子
  //! 
  //! @return 指定したI記述子の値
  //! 
  VALUE itype(char* record_id, char* itype_id);

};

#endif
