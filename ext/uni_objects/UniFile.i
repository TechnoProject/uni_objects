%{
#include <iostream>
#include <string>
#include "UniFile.hpp"
using namespace std;
%}
%include "UniFile.hpp"

%inline %{
  UniFile::UniFile() {
    file_id = 0;
    m_filename = NULL;
    max_buffer_size = 2048;
    buffer = new char[max_buffer_size];
    #ifdef DEBUG
    cerr<<"UniFile Constractor: "<< (long)buffer <<endl;
    #endif
  }

  UniFile::~UniFile() {
    #ifdef DEBUG
    cerr<<"UniFile Destractor: "<< (long)buffer <<endl;
    #endif
    delete [] buffer;
    if (m_filename) {
      delete [] m_filename;
      m_filename = NULL;
    }
  }

  UniFile::UniFile(const UniFile& x) {
    if(this!=&x) {
      file_id = x.file_id;
      max_buffer_size = 2048;
      buffer = new char[max_buffer_size];
      #ifdef DEBUG
      cerr<<"UniFile Copy Constractor: "<<(long)buffer<<" From "<<(long)x.buffer<<endl;
    } else {
      cerr<<"Ignored UniFile Copy Constractor"<<endl;
      #endif
    }
  }

  VALUE UniFile::open(char* filename) {
    long dict_flag = IK_DATA;
    long len = strlen(filename);
    m_filename = new char[len+1];
    strcpy(m_filename, filename);
    long status_func = 0, code = 0;
    ic_open(&file_id, &dict_flag, m_filename, &len, &status_func, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    VALUE rFile = SWIG_NewPointerObj(this,SWIGTYPE_p_UniFile,true);
    if(rb_block_given_p()) {
      rb_yield(rFile);
      this->close();
      return Qnil;
    } else {
      return rFile;
    }
  }

  void UniFile::clear() {
    long code = 0;
    ic_clearfile(&file_id, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniFile::close() {
    long code = 0;
    ic_close(&file_id, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    if (m_filename) {
      delete [] m_filename;
      m_filename = NULL;
    }
  }

  VALUE UniFile::read(VALUE record_id,long lock) {
    if( TYPE(record_id)!=T_STRING ) record_id = rb_funcall(record_id, rb_intern("to_s"),0);
    long status_func = 0, code = 0, buffer_len = 0, rec_id_len = RSTRING_LEN(record_id);
    char *record_id_cstr = RSTRING_PTR(record_id);
    ic_read(&file_id, &lock, record_id_cstr, &rec_id_len, buffer, &max_buffer_size, &buffer_len, &status_func, &code);
    if(code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] buffer;
      max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      buffer = new char[max_buffer_size];
      buffer_len = 0;
      ic_read(&file_id, &lock, record_id_cstr, &rec_id_len, buffer, &max_buffer_size, &buffer_len, &status_func, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer, buffer_len);
  }

  VALUE UniFile::readfield(VALUE record_id, long field_number, long lock) {
    if( TYPE(record_id)!=T_STRING ) record_id = rb_funcall(record_id, rb_intern("to_s"),0);
    long status_func = 0, code = 0, buffer_len = 0, rec_id_len = RSTRING_LEN(record_id);
    char *record_id_cstr = RSTRING_PTR(record_id);
    ic_readv(&file_id, &lock, record_id_cstr, &rec_id_len, &field_number, buffer, &max_buffer_size, &buffer_len, &status_func, &code);
    if(code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] buffer;
      max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      buffer = new char[max_buffer_size];
      buffer_len = 0;
      ic_readv(&file_id, &lock, record_id_cstr, &rec_id_len, &field_number, buffer, &max_buffer_size, &buffer_len, &status_func, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)buffer<<" max: "<<max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer, buffer_len);
  }

  void UniFile::write(VALUE record_id, VALUE record, long lock) {
    // 型チェック
    if( TYPE(record_id)!=T_STRING )
      record_id = rb_funcall(record_id, rb_intern("to_s"),0);
    if( TYPE(record)!=T_STRING )
      record = rb_funcall(record, rb_intern("to_s"),0);
    // 主処理
    long status_func = 0, code = 0, rec_id_len = RSTRING_LEN(record_id), record_len = RSTRING_LEN(record);
    char *record_id_cstr = RSTRING_PTR(record_id), *record_cstr = RSTRING_PTR(record);
    ic_write(&file_id, &lock, record_id_cstr, &rec_id_len, record_cstr, &record_len, &status_func, &code);
    // 例外通知
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniFile::writefield(VALUE record_id, long field_number, VALUE field, long lock) {
    // 型チェック
    if( TYPE(record_id)!=T_STRING )
      record_id = rb_funcall(record_id, rb_intern("to_s"),0);
    if( TYPE(field)!=T_STRING )
      field = rb_funcall(field, rb_intern("to_s"),0);
    // 主処理
    long status_func = 0, code = 0, rec_id_len = RSTRING_LEN(record_id), field_len = RSTRING_LEN(field);
    char *record_id_cstr = RSTRING_PTR(record_id), *field_cstr = RSTRING_PTR(field);
    ic_writev(&file_id, &lock, record_id_cstr, &rec_id_len, &field_number, field_cstr, &field_len, &status_func, &code);
    // 例外通知
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniFile::release(VALUE record_id) {
    if( TYPE(record_id)!=T_STRING )
      record_id = rb_funcall(record_id, rb_intern("to_s"),0);
    long code = 0, rec_id_len = RSTRING_LEN(record_id);
    char *record_id_cstr = RSTRING_PTR(record_id);
    ic_release(&file_id, record_id_cstr, &rec_id_len, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  void UniFile::deleterecord(VALUE record_id, long lock) {
    if( TYPE(record_id)!=T_STRING )
      record_id = rb_funcall(record_id, rb_intern("to_s"),0);
    long status_func = 0, code = 0, rec_id_len = RSTRING_LEN(record_id);
    char *record_id_cstr = RSTRING_PTR(record_id);
    ic_delete(&file_id, &lock, record_id_cstr, &rec_id_len, &status_func, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  VALUE UniFile::itype(char* record_id, char* itype_id) {
    if (m_filename==NULL) {
      throw UniError(30112,__PRETTY_FUNCTION__);
    }
    long filename_len = strlen(m_filename);
    long record_id_len = strlen(record_id);
    long itype_id_len = strlen(itype_id);
    long buffer_len=0, code=0;
    ic_itype (m_filename, &filename_len, record_id, &record_id_len, itype_id, &itype_id_len, buffer, &max_buffer_size, &buffer_len, &code);
    
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(buffer,buffer_len);
  }
%}

