#ifndef INCLUDED_UNIDICTIONARY
#define INCLUDED_UNIDICTIONARY

using namespace std;

//! Reading and modifying sequential files(シーケンシャルファイルの読み込みと変更)
//  Managing database files(管理するデータベースファイル)
class UniDictionary : public UniFile {

public:

  //! デストラクタ
  virtual ~UniDictionary();

  //! ディクショナリファイルをオープンする
  //! 
  //! @param filename  ファイル名
  //! 
  //! @return ブロック指定あり -> nil, ブロック指定なし -> File
  //! 
  VALUE open(char* filename);

};

#endif
