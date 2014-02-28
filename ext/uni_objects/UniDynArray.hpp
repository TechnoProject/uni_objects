using namespace std;

//! Accessing and modifying strings(文字列へのアクセスと修正)
class UniDynArray {

  char *mp_value;
  long m_length;
  long m_max_value_len;

  char *m_buffer;
  long m_max_buffer_size;

  long m_position;

public:

  //! コンストラクタ
  UniDynArray(VALUE value);

  //! デストラクタ
  virtual ~UniDynArray(); 

  //! データを削除する
  //! 
  //! @param field    削除するフィールドの数
  //! @param value    削除する値の数
  //! @param subvalue 削除するサブ値の数
  //! 
  //! @return なし
  //! 
  void del(long field, long value=0, long subvalue=0); 

  //! データを抽出する
  //! 
  //! @param field    抽出するフィールドの数
  //! @param value    抽出する値の数
  //! @param subvalue 抽出するサブ値の数
  //! 
  //! @return 抽出したデータ
  //! 
  VALUE extract(long field, long value=0, long subvalue=0); 

  //! 指定したフィールド、値、サブ値を挿入する
  //! 
  //! @param str      挿入する文字列
  //! @param field    挿入するフィールドの数
  //! @param value    挿入する値の数
  //! @param subvalue 挿入するサブ値の数
  //! 
  //! @return なし
  //! 
  void insert(VALUE str, long field, long value=0, long subvalue=0); 

  //! 文字列のダイナミックアレイを検索し、式が配列および/または配列ではない場合の式が行くべきであることを示す値を返す
  //! 
  //! @param  str      探索する文字列
  //! @param  field    探索を開始するフィールドの位置
  //! @param  value    探索を開始する値の位置
  //! @param  subvalue 探索を開始するサブ値の位置
  //! @param  order    ダイナミックアレイ内の要素の順序を示す文字列
  //!  <br>　　AL or A = Ascending, left-justified
  //!  <br>　　AR = Ascending, right-justified
  //!  <br>　　D = Descending, left-justified
  //!  <br>　　DR = Descending, right-justified
  //! 
  //! @return 
  //!      　　検索できた場合 -> 検索文字列のダイナミックアレイ内の位置
  //!  <br>　　検索できなかった場合 -> Qnil
  //! 
  VALUE locate(VALUE str, long field=1, long value=0, long subvalue=0, char *order="AL");

  //! ダイナミックアレイ内のデータを置換する
  //! 
  //! @param rstring  指定された部分文字列を置換する文字列
  //! @param field    置換するフィールドの数
  //! @param value    置換する値の数
  //! @param subvalue 置換するサブ値の数
  //! 
  //! @return なし
  //! 
  void replace(VALUE rstring, long field=0, long value=0, long subvalue=0);

  //! 配列を文字列に変換する
  //! 
  //! @param なし
  //! 
  //! @return 変換後の文字列
  //! 
  VALUE to_s();

  //! 要素を順番に取り出してブロックに渡す
  //! 
  //! @param なし
  //! 
  //! @return Qnil
  //! 
  VALUE each();

  //! 文字列がアルファベットか判断する
  //! 
  //! @param value 調査対象の文字列
  //! 
  //! @return code 
  //!  <br>　　アルファベットのみの場合 -> 1
  //!  <br>　　アルファベット以外を含む場合 -> 0
  //! 
  static bool alpha(VALUE value);

protected:

  //! ダイナミックアレイの連続した部分文字列を移動する
  //! 
  //! @param なし
  //! 
  //! @return 移動後のポインタの位置
  //! 
  VALUE remove();

};
