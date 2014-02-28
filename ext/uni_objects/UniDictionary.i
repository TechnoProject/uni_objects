%{
#include <iostream>
#include <string>
#include "UniDictionary.hpp"
using namespace std;
%}
%include "UniDictionary.hpp"

%inline %{

  UniDictionary::~UniDictionary() {
    #ifdef DEBUG
    cerr<<"UniDictionary Destractor: "<< (long)buffer <<endl;
    #endif
  }

  VALUE UniDictionary::open(char* filename) {
    long dict_flag = IK_DICT;
    long len = strlen(filename);
    m_filename = new char[len+1];
    strcpy(m_filename, filename);
    long status_func = 0, code = 0;
    ic_open(&file_id, &dict_flag, m_filename, &len, &status_func, &code);
    if(code!=0) throw UniError(code,__PRETTY_FUNCTION__);
    VALUE rFile = SWIG_NewPointerObj(this,SWIGTYPE_p_UniDictionary,true);
    if(rb_block_given_p()) {
      rb_yield(rFile);
      this->close();
      return Qnil;
    } else {
      return rFile;
    }
  }

%}
