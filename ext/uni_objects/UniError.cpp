#include <iostream>
#include <string>
#include "intcall.h"
#include "ruby.h"
#include "UniError.hpp"

  UniError::UniError(long code, const char* func) {
    m_code=code;
    strcpy(mp_func, func);
  }

  UniError::~UniError() {}

  VALUE UniError::code() {
    return INT2NUM(m_code);
  }

  VALUE UniError::message() {
    char msg[2048];
    sprintf(msg,"UniError(%ld) in '%s' method.", m_code, mp_func);
    return rb_str_new2(msg);
  }

  VALUE UniError::to_s() {
    return message();
  }

