//! Processing at the time of the error(エラー時の処理)
class UniError {

  long  m_code;
  char  mp_func[1024];

public:

  //! コンストラクタ
  UniError(long code, const char* func);

  //! デストラクタ
  virtual ~UniError();

  //! コード値を返す 
  VALUE code();

  //! メッセージを出力する 
  VALUE message();

  //! UniError.message()を呼び出す
  VALUE to_s();

};

