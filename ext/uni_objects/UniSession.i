%{
#include <iostream>
#include <string>
#include "UniSession.hpp"
using namespace std;
%}
%include "UniSession.hpp"

%inline %{
  UniSession::UniSession(char *server,char *userid, char *password, char *account, char *subkey) : IM("\xFF",1), AM("\xFE",1) {
    m_server = server;
    m_userid = userid;
    m_password = password;
    m_account = account;
    m_subkey = subkey;
    m_readnext_code = 0;
    m_session_id = 0;
    
    buffer = new char[max_buffer_size=2048];
    #ifdef DEBUG
    cerr<<"UniSession Constractor: "<< (long)buffer <<endl;
    #endif
  }

  UniSession::~UniSession() {
    #ifdef DEBUG
    cerr<<"UniSession Destractor: "<< (long)buffer <<endl;
    #endif
    delete [] buffer;
  }
  
  VALUE UniSession::open() {
    long status=0;
    m_session_id = ic_opensession((char*)m_server.c_str(),(char*)m_userid.c_str(),(char*)m_password.c_str(),(char*)m_account.c_str(),&status,(char*)m_subkey.c_str());
    if(status!=0) throw UniError(status,__PRETTY_FUNCTION__);
    VALUE rSession = SWIG_NewPointerObj(this,SWIGTYPE_p_UniSession,true);
    IM = get_mark_value(IK_IM);
    AM = get_mark_value(IK_AM);
    FM = AM;
    VM = get_mark_value(IK_VM);
    SM = get_mark_value(IK_SM);
    TM = get_mark_value(IK_TM);
    SQLNULL = get_mark_value(IK_NULL);
    if(rb_block_given_p()) {
      // Rubyでブロックが指定された時の処理
      rb_yield(rSession);
      long code=0;
      ic_quit(&code);
      return Qnil;
    } else {
      // Rubyでブロックが指定されなかった時の処理
      return rSession;
    }
  }

  VALUE UniSession::open(char* filename) { 
    UniFile *pFile = new UniFile();
    return pFile->open(filename);
  }

  VALUE UniSession::opendict(char* filename) { 
    UniDictionary *pDict = new UniDictionary();
    return pDict->open(filename);
  }

  VALUE UniSession::execute(char* command) {
    long return_code1 = 0, return_code2 = 0, code = 0, command_len = strlen(command), buffer_len = 0;
    ic_execute(command,&command_len,buffer,&max_buffer_size,&buffer_len,&return_code1,&return_code2,&code);
    #ifdef DEBUG
    cerr<<"buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
    cerr<<"string: "<<string(buffer,buffer_len);
    #endif
    if ( code!=0 && code!=22002 ) throw UniError(code,__PRETTY_FUNCTION__);
    status_code = code;
    return rb_str_new(buffer,buffer_len);
  }

  VALUE UniSession::executecontinue() {
    VALUE result = Qnil;
    long return_code1 = 0, return_code2 = 0, code = 0, buffer_len = 0;
    if ( status_code == 22002 ) {
      ic_executecontinue(buffer,&max_buffer_size,&buffer_len,&return_code1,&return_code2,&code);
      status_code = code;
      if ( code!=0 && code!=22002 ) throw UniError(code,__PRETTY_FUNCTION__);
      #ifdef DEBUG
      cerr<<string(buffer,buffer_len)<<endl;
      #endif
      result = rb_str_new( buffer, buffer_len );
    }
    return result;  
  }

  void UniSession::data(VALUE data) {
    long  data_len = RSTRING_LEN(data), code = 0;
    char* data_ptr = RSTRING_PTR(data);
    ic_data(data_ptr, &data_len, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniSession::clear_data() {
    long code=0;
    ic_cleardata(&code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniSession::quit() {
    long code=0;
    ic_quit(&code);
  }

  VALUE UniSession::itype(char* filename, char* record_id, char* itype_id) {
    long filename_len = strlen(filename);
    long record_id_len = strlen(record_id);
    long itype_id_len = strlen(itype_id);
    long buffer_len=0, code=0;
    ic_itype (filename, &filename_len, record_id, &record_id_len, itype_id, &itype_id_len, buffer, &max_buffer_size, &buffer_len, &code);
    
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer,buffer_len);
  }

  void UniSession::subcall1(char* subname, long argnum, std::string & arg1){
    long subname_len = strlen(subname);
    long code = 0;
    ICSTRING args1;
    args1=setArgs(arg1);

    ic_subcall(subname, &subname_len, &code, &argnum, &args1);
    
    arg1.assign((char*)args1.text, args1.len);
    delete [] args1.text;
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniSession::subcall2(char* subname, long argnum, std::string & arg1, std::string & arg2) {
    long subname_len = strlen(subname);
    long code = 0;
    ICSTRING args1;
    ICSTRING args2;
    args1=setArgs(arg1);
    args2=setArgs(arg2);
    
    ic_subcall(subname, &subname_len, &code, &argnum, &args1, &args2);
    
    arg1.assign((char*)args1.text, args1.len);
    arg2.assign((char*)args2.text, args2.len);
    delete [] args1.text;
    delete [] args2.text;
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniSession::subcall3(char* subname, long argnum, std::string & arg1, std::string & arg2, std::string & arg3) {
    long subname_len = strlen(subname);
    long code = 0;
    ICSTRING args1;
    ICSTRING args2;
    ICSTRING args3;
    args1=setArgs(arg1);
    args2=setArgs(arg2);
    args3=setArgs(arg3);
    
    ic_subcall(subname, &subname_len, &code, &argnum, &args1, &args2, &args3);
    
    arg1.assign((char*)args1.text, args1.len);
    arg2.assign((char*)args2.text, args2.len);
    arg3.assign((char*)args3.text, args3.len);
    delete [] args1.text;
    delete [] args2.text;
    delete [] args3.text;
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  ICSTRING UniSession::setArgs(std::string arg1)
  {
    ICSTRING args1;
    args1.len = 0;

    const char* ptr =  arg1.c_str();
    long  len =  arg1.length();
    char* text = (char*)malloc(len);
    memcpy(text,ptr,len);
    args1.text =(unsigned char*)text;
    args1.len = len;

    return args1;
  }

  VALUE UniSession::readnext(long select_list_num) {
    long buffer_len=0;
    ic_readnext(&select_list_num, buffer, &max_buffer_size, &buffer_len, &m_readnext_code);
    if(m_readnext_code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] buffer;
      max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      buffer = new char[max_buffer_size];
      buffer_len = 0;
      ic_readnext(&select_list_num, buffer, &max_buffer_size, &buffer_len, &m_readnext_code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(m_readnext_code!=0 && m_readnext_code!=22004)
      throw UniError(m_readnext_code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer, buffer_len);
  }

  VALUE UniSession::each(int select_list_num) {
    m_readnext_code = 0;
    VALUE result = Qnil;
    if(rb_block_given_p()) {
      while(true) {
        VALUE record_id = readnext(select_list_num);
        if(m_readnext_code!=0) break;
        result = rb_yield(record_id);
      }
    }
    return result;
  }

  void UniSession::set_map(VALUE map_string) {
    long status=0, code=0;
    long length = RSTRING_LEN(map_string);
    char *map_cstr = RSTRING_PTR(map_string);
    ic_set_map(map_cstr,&length,&status,&code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  VALUE UniSession::get_map() {
    long buffer_len = max_buffer_size, code = 0;
    ic_get_map(buffer, &max_buffer_size, &buffer_len, &code);
    if(code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] buffer;
      max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      buffer = new char[max_buffer_size];
      buffer_len = max_buffer_size;  // この関数はbuffer_lenに値を必要とする
      ic_get_map(buffer, &max_buffer_size, &buffer_len, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer,buffer_len);
  }

  void UniSession::set_locale(long key, VALUE locale_string) {
    long status=0, code=0;
    long length = RSTRING_LEN(locale_string);
    char *locale_cstr = RSTRING_PTR(locale_string);
    ic_set_locale(&key, locale_cstr, &length, &status, &code);
    #ifdef DEBUG
    cerr<<"locale: "<<string(locale_cstr,length)<<" status: "<<status<<endl;
    #endif
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  VALUE UniSession::get_locale(long key) {
    long buffer_len = max_buffer_size, code = 0;
    ic_get_locale(&key, buffer, &max_buffer_size, &buffer_len, &code);
    if(code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] buffer;
      max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      buffer = new char[max_buffer_size];
      buffer_len = max_buffer_size;  // この関数はbuffer_lenに値を必要とする
      ic_get_locale(&key, buffer, &max_buffer_size, &buffer_len, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer,buffer_len);
  }

  string UniSession::get_mark_value(long key) {
    long buffer_len=max_buffer_size, code=0;
    ic_get_mark_value(&key, buffer, &max_buffer_size, &buffer_len, &code);
    if(code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] buffer;
      max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      buffer = new char[max_buffer_size];
      buffer_len = max_buffer_size;  // この関数はbuffer_lenに値を必要とする
      ic_get_mark_value(&key, buffer, &max_buffer_size, &buffer_len, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return string(buffer,buffer_len);
  }

  void UniSession::free(void* ptr) {
    ic_free(ptr);
  }
%}

