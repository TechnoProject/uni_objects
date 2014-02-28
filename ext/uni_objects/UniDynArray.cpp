#include <iostream>
#include <string>
#include "intcall.h"
#include "ruby.h"
#include "UniError.hpp"
#include "UniDynArray.hpp"

  UniDynArray::UniDynArray(VALUE value) {
    m_position = 0;
    m_buffer = new char[m_max_buffer_size=2048];
    m_length = RSTRING_LEN(value);
    mp_value = new char[ m_max_value_len = (m_length/2048+1)*1024 ];
    strncpy(mp_value, RSTRING_PTR(value), m_length);
    #ifdef DEBUG
    cerr<<"UniDynArray Constractor: "<< (long)mp_value <<endl;
    #endif
  }

  UniDynArray::~UniDynArray() {
    #ifdef DEBUG
    cerr<<"UniDynArray Destractor: "<< (long)mp_value <<endl;
    #endif
    delete mp_value;
    delete m_buffer;
  }

  void UniDynArray::del(long field, long value, long subvalue) {
    long code=0;
    ic_strdel(mp_value, &m_length, &field, &value, &subvalue, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  VALUE UniDynArray::extract(long field, long value, long subvalue) {
    long code=0, buffer_len = 0;
    ic_extract(mp_value, &m_length, &field, &value, &subvalue, m_buffer, &m_max_buffer_size, &buffer_len, &code);
    if(code==22002) {
      delete [] m_buffer;
      m_max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      m_buffer = new char[m_max_buffer_size];
      buffer_len = 0;
      ic_extract(mp_value, &m_length, &field, &value, &subvalue, m_buffer, &m_max_buffer_size, &buffer_len, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)m_buffer<<" max: "<<m_max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return rb_str_new(m_buffer,buffer_len);
  }

  void UniDynArray::insert(VALUE str, long field, long value, long subvalue) {
    long code=0;
    long str_len = RSTRING_LEN(str);
    char *str_cstr = RSTRING_PTR(str);
    ic_insert(mp_value,&m_max_value_len,&m_length,&field,&value,&subvalue,str_cstr,&str_len,&code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  VALUE UniDynArray::locate(VALUE str, long field, long value, long subvalue, char *order) {
    long index=0, found=0, code=0;
    long str_len = RSTRING_LEN(str);
    long order_len = strlen(order);
    if(field<1) field=1;
    ic_locate(RSTRING_PTR(str), &str_len, mp_value, &m_length, &field, &value, &subvalue, order, &order_len, &index, &found, &code);
    #ifdef DEBUG
    cerr<<"found: "<<found<<" index: "<<index<<endl;
    #endif
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    return found==0 ? Qnil : INT2NUM(index);
  }

  void UniDynArray::replace(VALUE rstring, long field, long value, long subvalue) {
    char *c_str = RSTRING_PTR(rstring);
    long len = RSTRING_LEN(rstring), code = 0;
    ic_replace(mp_value, &m_max_value_len, &m_length, &field, &value, &subvalue, c_str, &len, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
  }

  VALUE UniDynArray::to_s() {
    return rb_str_new(mp_value,m_length);
  }

  VALUE UniDynArray::each() {
    if(rb_block_given_p()) {
      for(VALUE item = remove(); item!=Qnil; item = remove()) {
        rb_yield(item);
      }
      return Qnil;
    } else {
      return Qnil;
    }
  }

  bool UniDynArray::alpha(VALUE value) {
    long code = 0;
    long len = RSTRING_LEN(value);
    char *c_str = RSTRING_PTR(value);
    ic_alpha(c_str,&len,&code);
    if(code!=0 && code!=1) throw UniError(code,__PRETTY_FUNCTION__);
    return code;
  }

  VALUE UniDynArray::remove() {
    if(m_length<m_position) {
      m_position = 0;
      return Qnil;
    }
    long delimiter = 0, buffer_len = 0, code=0;
    ic_remove(mp_value, &m_length, m_buffer, &m_max_buffer_size, &buffer_len, &delimiter, &m_position, &code);
    #ifdef DEBUG
    cerr<<"string: "<<string(m_buffer,buffer_len)<<" pointer: "<<m_position<<" length: "<<buffer_len<<" delimiter: "<<delimiter<<endl;
    #endif
    if(code==22002) { // バッファのサイズが不足のためサイズを増やして再試行
      delete [] m_buffer;
      m_max_buffer_size = (buffer_len/1024+1)*1024; // 1024Byte=1KBずつ増加
      m_buffer = new char[m_max_buffer_size];
      buffer_len = 0;
      ic_remove(mp_value, &m_length, m_buffer, &m_max_buffer_size, &buffer_len, &delimiter, &m_position, &code);
      #ifdef DEBUG
      cerr<<"Retry "<<__FUNCTION__<<". buffer: "<<(long)m_buffer<<" max: "<<m_max_buffer_size<<" buf_len: "<<buffer_len<<endl;
      #endif
    }
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    VALUE a = rb_ary_new3(2,rb_str_new(m_buffer,buffer_len), INT2NUM(delimiter));
    return a;
  }

