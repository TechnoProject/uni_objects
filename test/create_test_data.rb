#!/usr/local/bin/ruby
#encoding: utf-8

################################################################################
# create
# 
# table:
#   CLEAR_TEST
#   WRITE_TEST
#   READ_TEST
#   READNEXT_TEST
# subroutine:
#   SUBCALL1
#   SUBCALL2
#   SUBCALL3
# BASIC program:
#   OVERTEST
#   WITHINTEST
################################################################################
# table data
# 
# CLEAR_TEST data:
#   no data
# 
# WRITE_TEST data:
# --- ----------- ------- --------
# 0   scissors    300     10      
#     pencil      50      20      
# 1   scissors    300     10      
#     pencil      50      20      
# 2   scissors    300     10      
#     pencil      50      20      
# 3   scissors    300     10      
#     pencil      50      20      
# 4   scissors    300     10      
#     pencil      50      20      
# 
# READ_TEST dictionary:
#                Type &
# Field          Field  Field         Conversion   Column          Output Depth & 
# Name           Number Definition    Code         Heading         Format Assoc   
# -------------- ------ ------------- ------------ --------------- ------ --------
# @ID            D    0                            ID              5R     S
# TANTO          D    1                            tanto           10L    S
# HIZUKE         D    2               D/YMD[4,2,2] hizuke          10L    S
# SHOHIN         D    3                            shohin          10L    M MEISAI
# TANKA          D    4                            tanka           8R     M MEISAI
# SURYO          D    5                            suryo           5R     M MEISAI
# KINGAKU        I      TANKA*SURYO                kingaku         8R     M MEISAI
# GOKEI          I      SUM(TANKA*SUR              gokei           8R     S
#                       YO)
# MEISAI         PH     SHOHIN TANKA
#                       SURYO KINGAKU
# @              PH     @ID TANTO
#                       HIZUKE SHOHIN
#                       TANKA SURYO
#                       KINGAKU GOKEI
# 
# READ_TEST data:
# ID    tanto      hizuke     shohin     tanka    suryo kingaku  gokei
# ----- ---------- ---------- ---------- -------- ----- -------- --------
#     1 SATOU      2011/12/10 pencil           50   100     5000     5000
#     2 SUZUKI     2011/12/11 eraser           50   120     6000     6000
#     3 WATANABE   2011/12/12 scissors        300    10     3000     4000
#                             pencil           50    20     1000
# 
# READNEXT_TEST data:
#   1 record: @ID = "0"
# 
################################################################################
# copy file
# 
# subroutine file: BP/SUBCALL1
#   SUBROUTINE (result1)
#     result1=result1:" subcall ":result1
#   RETURN
# 
# subroutine file: BP/SUBCALL2
#   SUBROUTINE (result1, result2)
#     result1=result1:" subcall ":result1
#     result1=result2:" subcall ":result2
#   RETURN
# 
# subroutine file: BP/SUBCALL3
#   SUBROUTINE (result1, result2, result3)
#     result1=result1:" subcall ":result1
#     result1=result2:" subcall ":result2
#     result1=result3:" subcall ":result3
#   RETURN
# 
# BASIC program file: BP/OVERTEST
#   str=(2048 byte string):(2048 byte string):"SAMPLE3"
#   PRINT str
#   END
# 
################################################################################

def create_table_clear_test
  begin
    @file_clear=@session.open('CLEAR_TEST')
  rescue
    @session.execute('CREATE.FILE CLEAR_TEST 18 1409 2')
    @file_clear=@session.open('CLEAR_TEST')
  end
end

def create_table_write_test
  begin
    @file_write=@session.open('WRITE_TEST')
  rescue
    @session.execute('CREATE.FILE WRITE_TEST 18 1409 2')
    @file_write=@session.open('WRITE_TEST')
  end
end

def create_data_write_test
  @file_write.write(0, "scissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
  @file_write.write(1, "scissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
  @file_write.write(2, "scissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
  @file_write.write(3, "scissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
  @file_write.write(4, "scissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
end

def create_table_read_test
  begin
    @file_read=@session.open('READ_TEST')
  rescue
    @session.execute('CREATE.FILE READ_TEST 18 1409 2')
    @file_read=@session.open('READ_TEST')
    @file_read.clear
  end
  @file_dict=@session.opendict('READ_TEST')
  @file_dict.clear
end

def create_data_read_test
  # create dictionary
  @file_dict.write("@ID", "D\xEF\xA3\xBE0\xEF\xA3\xBE\xEF\xA3\xBEREAD_TEST\xEF\xA3\xBE5R\xEF\xA3\xBES")
  @file_dict.write("TANTO", "D\xEF\xA3\xBE1\xEF\xA3\xBE\xEF\xA3\xBEtanto\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @file_dict.write("HIZUKE", "D\xEF\xA3\xBE2\xEF\xA3\xBED/YMD[4,2,2]\xEF\xA3\xBEhizuke\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @file_dict.write("SHOHIN", "D\xEF\xA3\xBE3\xEF\xA3\xBE\xEF\xA3\xBEshohin\xEF\xA3\xBE10L\xEF\xA3\xBEM\xEF\xA3\xBEMEISAI")
  @file_dict.write("TANKA", "D\xEF\xA3\xBE4\xEF\xA3\xBE\xEF\xA3\xBEtanka\xEF\xA3\xBE8R\xEF\xA3\xBEM\xEF\xA3\xBEMEISAI")
  @file_dict.write("SURYO", "D\xEF\xA3\xBE5\xEF\xA3\xBE\xEF\xA3\xBEsuryo\xEF\xA3\xBE5R\xEF\xA3\xBEM\xEF\xA3\xBEMEISAI")
  @file_dict.write("GOKEI", "I\xEF\xA3\xBESUM(TANKA*SURYO)\xEF\xA3\xBE\xEF\xA3\xBEgokei\xEF\xA3\xBE8R\xEF\xA3\xBES")
  @file_dict.write("KINGAKU", "I\xEF\xA3\xBETANKA*SURYO\xEF\xA3\xBE\xEF\xA3\xBEkingaku\xEF\xA3\xBE8R\xEF\xA3\xBEM\xEF\xA3\xBEMEISAI")
  @file_dict.write("MEISAI", "PH\xEF\xA3\xBESHOHIN TANKA SURYO KINGAKU")
  @file_dict.write("@", "PH\xEF\xA3\xBETANTO HIZUKE SHOHIN TANKA SURYO KINGAKU GOKEI")
  # create data
  @file_read.write(1, "SATOU\xEF\xA3\xBE2011/12/10\xEF\xA3\xBEpencil\xEF\xA3\xBE50\xEF\xA3\xBE100")
  @file_read.write(2, "SUZUKI\xEF\xA3\xBE2011/12/11\xEF\xA3\xBEeraser\xEF\xA3\xBE50\xEF\xA3\xBE120")
  @file_read.write(3, "WATANABE\xEF\xA3\xBE2011/12/12\xEF\xA3\xBEscissors\xEF\xA3\xBDpencil\xEF\xA3\xBE300\xEF\xA3\xBD50\xEF\xA3\xBE10\xEF\xA3\xBD20")
  # for I-FIELD compile
  @session.execute('LIST READ_TEST')
end

def create_table_readnext_test
  begin
    @file_readnext=@session.open('READNEXT_TEST')
  rescue
    @session.execute('CREATE.FILE READNEXT_TEST 18 1409 2')
    @file_readnext=@session.open('READNEXT_TEST')
  end
end

def create_data_readnext_test
  @file_readnext.write(0, "test")
end

def create_table_bp
  begin
    @session.execute('CREATE.FILE BP 19')
  rescue
  end
end

def copy_files
  from_dir = String.new(Dir::pwd)
  to_dir = String.new(ENV['account'])
  from_dir << "/test/data"
  to_dir << "/BP"
  
  files = Dir::entries(from_dir)
  files.each {|file|
    unless file == "." || file == ".."
      from_file = from_dir + "/" + file
      FileUtils.cp( from_file, to_dir )
    end
  }
end

def create_subroutine
  # compile
  @session.execute('BASIC BP SUBCALL1')
  @session.execute('BASIC BP SUBCALL2')
  @session.execute('BASIC BP SUBCALL3')
  # CATALOG
  @session.execute('CATALOG BP SUBCALL1 LOCAL')
  @session.execute('CATALOG BP SUBCALL2 LOCAL')
  @session.execute('CATALOG BP SUBCALL3 LOCAL')
end

def create_basic_program
  # compile
  @session.execute('BASIC BP WITHINTEST')
  @session.execute('BASIC BP OVERTEST')
end

