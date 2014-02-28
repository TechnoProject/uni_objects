require 'mkmf'

#ictcall_header_path = "/opt/4ddam/unishared/icsdk"
ictcall_header_path = "/usr/uv/uv/unishared.load/icsdk"
current_path = File.expand_path('../', __FILE__)

swig_cmd = find_executable "swig"
%x{#{swig_cmd} -ruby -c++ -I#{ictcall_header_path} #{current_path}/UniObject.i }

$libs += "-luvic -lstdc++"
#$CFLAGS += " -I#{ictcall_header_path}"
#$CPPFLAGS += " -I#{ictcall_header_path}"
#$LDFLAGS += " -L#{ictcall_header_path}"
dir_config("uni_objects", ictcall_header_path, ictcall_header_path)

create_makefile("UniObjects")
