#ifndef INCLUDED_UNIOBJECT
#define INCLUDED_UNIOBJECT

#include "ruby.h"
using namespace std;

//! データベース・サーバ上でセッションを開始する
//! 
//! @param server   
//! @param userid   
//! @param password 
//! @param account  
//! 
//! @return UniSession.open
//! 
VALUE open(char *server,char *userid, char *password, char *account);

//! すべてのセッションを終了する
//! 
void quitall();

#endif
