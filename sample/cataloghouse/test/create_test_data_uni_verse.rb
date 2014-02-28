#!/usr/local/bin/ruby
#encoding: utf-8

################################################################################
# create
# 
# table:
#   USERS
#   CUSTOMERS
################################################################################
# table data
# 
# USERS dictionary:
#                Type &
# Field......... Field. Field........ Conversion.. Column......... Output Depth &
# Name.......... Number Definition... Code........ Heading........ Format Assoc..
# 
# @ID            D    0                            USERS           5R     S
# LAST_NAME      D    1                            last_name       10L    S
# FIRST_NAME     D    2                            first_name      10L    S
# GENDER         D    3                            gender          10L    S
# DOB            D    4                            dob             10L    S
# @              PH     LAST_NAME
#                       FIRST_NAME
#                       GENDER DOB
# 
# USERS data:
# 
# USERS    last_name.    first_name    gender....    dob.......
# -------- ------------- ------------- ------------- ----------
#     1    SATOU         Yuma          1             19750128
#     2    SUZUKI        Takahiro      1             19750218
#     3    TAKAHASHI     Ren           1             19770308
#     4    TANAKA        Yuina         2             19780421
#     5    ITO           Aoi           2             19790522
# 
# CUSTOMERS dictionary:
#                Type &
# Field......... Field. Field........ Conversion.. Column......... Output Depth &
# Name.......... Number Definition... Code........ Heading........ Format Assoc..
# 
# @ID            D    0                            CUSTOMERS       5R     S
# LAST_NAME      D    1                            last_name       10L    S
# FIRST_NAME     D    2                            first_name      10L    S
# GENDER         D    3                            gender          10L    S
# DOB            D    4                            dob             10L    S
# RECEIVE_IDS    D    5                            receive_ids     10L    S A1
# ITEM_ID        D    6                            item_id         10L    S A1
# SPFL           D    7                            spfl            10L    S A1
# SEQ            D    8                            seq             10L    S A1
# COLOR_SIZE1    D    9                            color_size1     10L    S A1
# COLOR_SIZE2    D   10                            color_size2     10L    S A1
# RECEIVE_CODE   D   11                            receive_code    10L    S A1
# A1             PH     RECEIVE_IDS
#                       ITEM_ID SPFL
#                       SEQ
#                       COLOR_SIZE1
#                       COLOR_SIZE2
#                       RECEIVE_CODE
# @              PH     LAST_NAME
#                       FIRST_NAME
#                       GENDER DOB
#                       RECEIVE_IDS
#                       ITEM_ID SPFL
#                       SEQ
#                       COLOR_SIZE1
#                       COLOR_SIZE2
#                       RECEIVE_CODE
# 
# CUSTOMERS data:
# 
# CUSTOMERS..     1
# last_name.. SATOU
# first_name. Yuma
# gender..... 1
# dob........ 19750128
# receive_ids item_id... spfl...... seq....... color_size1 color_size2 receive_code
# ----------- ---------- ---------- ---------- ----------- ----------- ------------
# 00-0001     k-00001    1          1          b20         b30         A01
# 00-0002     k-00002    1          1          r30         r40         A02
# 00-0003     k-00003    1          2          g20         g50         A01
# 
# CUSTOMERS..     2
# last_name.. SUZUKI
# first_name. Takahiro
# gender..... 1
# dob........ 19750218
# receive_ids item_id... spfl...... seq....... color_size1 color_size2 receive_code
# ----------- ---------- ---------- ---------- ----------- ----------- ------------
# 00-0001     k-00002    2          1          r20         r30         A01
# 00-0003     k-00003    1          1          g20         g50         A02
# 
# CUSTOMERS..     3
# last_name.. TAKAHASHI
# first_name. Ren
# gender..... 1
# dob........ 19770308
# receive_ids item_id... spfl...... seq....... color_size1 color_size2 receive_code
# 
# CUSTOMERS..     4
# last_name.. TANAKA
# first_name. Yuina
# gender..... 2
# dob........ 19780421
# receive_ids item_id... spfl...... seq....... color_size1 color_size2 receive_code
# 
# CUSTOMERS..     5
# last_name.. ITO
# first_name. Aoi
# gender..... 2
# dob........ 19790522
# receive_ids item_id... spfl...... seq....... color_size1 color_size2 receive_code
################################################################################

def create_table_users
  begin
    @file_user=@session.open('USERS')
    @file_user.clear
  rescue
    @session.execute('CREATE.FILE USERS 18 1409 2')
    @file_user=@session.open('USERS')
  end
  @dict_user=@session.opendict('USERS')
  @dict_user.clear
end

def create_data_users
  @dict_user.write("@ID", "D\xEF\xA3\xBE0\xEF\xA3\xBE\xEF\xA3\xBEUSERS\xEF\xA3\xBE5R\xEF\xA3\xBES")
  @dict_user.write("LAST_NAME", "D\xEF\xA3\xBE1\xEF\xA3\xBE\xEF\xA3\xBElast_name\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_user.write("FIRST_NAME", "D\xEF\xA3\xBE2\xEF\xA3\xBE\xEF\xA3\xBEfirst_name\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_user.write("GENDER", "D\xEF\xA3\xBE3\xEF\xA3\xBE\xEF\xA3\xBEgender\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_user.write("DOB", "D\xEF\xA3\xBE4\xEF\xA3\xBE\xEF\xA3\xBEdob\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_user.write("@", "PH\xEF\xA3\xBELAST_NAME FIRST_NAME GENDER DOB")
  @file_user.write(1, "SATOU\xEF\xA3\xBEYuma\xEF\xA3\xBE1\xEF\xA3\xBE19750128")
  @file_user.write(2, "SUZUKI\xEF\xA3\xBETakahiro\xEF\xA3\xBE1\xEF\xA3\xBE19750218")
  @file_user.write(3, "TAKAHASHI\xEF\xA3\xBERen\xEF\xA3\xBE1\xEF\xA3\xBE19770308")
  @file_user.write(4, "TANAKA\xEF\xA3\xBEYuina\xEF\xA3\xBE2\xEF\xA3\xBE19780421")
  @file_user.write(5, "ITO\xEF\xA3\xBEAoi\xEF\xA3\xBE2\xEF\xA3\xBE19790522")
end

def create_table_customers
  begin
    @file_customer=@session.open('CUSTOMERS')
    @file_customer.clear
  rescue
    @session.execute('CREATE.FILE CUSTOMERS 18 1409 2')
    @file_customer=@session.open('CUSTOMERS')
  end
  @dict_customer=@session.opendict('CUSTOMERS')
  @dict_customer.clear
end

def create_data_customers
  @dict_customer.write("@ID", "D\xEF\xA3\xBE0\xEF\xA3\xBE\xEF\xA3\xBECUSTOMERS\xEF\xA3\xBE5R\xEF\xA3\xBES")
  @dict_customer.write("LAST_NAME", "D\xEF\xA3\xBE1\xEF\xA3\xBE\xEF\xA3\xBElast_name\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_customer.write("FIRST_NAME", "D\xEF\xA3\xBE2\xEF\xA3\xBE\xEF\xA3\xBEfirst_name\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_customer.write("GENDER", "D\xEF\xA3\xBE3\xEF\xA3\xBE\xEF\xA3\xBEgender\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_customer.write("DOB", "D\xEF\xA3\xBE4\xEF\xA3\xBE\xEF\xA3\xBEdob\xEF\xA3\xBE10L\xEF\xA3\xBES")
  @dict_customer.write("RECEIVE_IDS", "D\xEF\xA3\xBE5\xEF\xA3\xBE\xEF\xA3\xBEreceive_ids\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("ITEM_ID", "D\xEF\xA3\xBE6\xEF\xA3\xBE\xEF\xA3\xBEitem_id\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("SPFL", "D\xEF\xA3\xBE7\xEF\xA3\xBE\xEF\xA3\xBEspfl\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("SEQ", "D\xEF\xA3\xBE8\xEF\xA3\xBE\xEF\xA3\xBEseq\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("COLOR_SIZE1", "D\xEF\xA3\xBE9\xEF\xA3\xBE\xEF\xA3\xBEcolor_size1\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("COLOR_SIZE2", "D\xEF\xA3\xBE10\xEF\xA3\xBE\xEF\xA3\xBEcolor_size2\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("RECEIVE_CODE", "D\xEF\xA3\xBE11\xEF\xA3\xBE\xEF\xA3\xBEreceive_code\xEF\xA3\xBE10L\xEF\xA3\xBEMS\xEF\xA3\xBEA1")
  @dict_customer.write("A1", "PH\xEF\xA3\xBERECEIVE_IDS ITEM_ID SPFL SEQ COLOR_SIZE1 COLOR_SIZE2 RECEIVE_CODE")
  @dict_customer.write("@", "PH\xEF\xA3\xBELAST_NAME FIRST_NAME GENDER DOB RECEIVE_IDS ITEM_ID SPFL SEQ COLOR_SIZE1 COLOR_SIZE2 RECEIVE_CODE")
  @file_customer.write(1, "SATOU\xEF\xA3\xBEYuma\xEF\xA3\xBE1\xEF\xA3\xBE19750128")
  @file_customer.writefield("1", 5, "00-0001\xEF\xA3\xBD00-0002\xEF\xA3\xBD00-0003")
  @file_customer.writefield("1", 6, "k-00001\xEF\xA3\xBDk-00002\xEF\xA3\xBDk-00003")
  @file_customer.writefield("1", 7, "1\xEF\xA3\xBD1\xEF\xA3\xBD1")
  @file_customer.writefield("1", 8, "1\xEF\xA3\xBD1\xEF\xA3\xBD2")
  @file_customer.writefield("1", 9, "b20\xEF\xA3\xBDr30\xEF\xA3\xBDg20")
  @file_customer.writefield("1", 10, "b30\xEF\xA3\xBDr40\xEF\xA3\xBDg50")
  @file_customer.writefield("1", 11, "A01\xEF\xA3\xBDA02\xEF\xA3\xBDA01")
  @file_customer.write(2, "SUZUKI\xEF\xA3\xBETakahiro\xEF\xA3\xBE1\xEF\xA3\xBE19750218")
  @file_customer.writefield("2", 5, "00-0001\xEF\xA3\xBD00-0003")
  @file_customer.writefield("2", 6, "k-00002\xEF\xA3\xBDk-00003")
  @file_customer.writefield("2", 7, "2\xEF\xA3\xBD1")
  @file_customer.writefield("2", 8, "1\xEF\xA3\xBD1")
  @file_customer.writefield("2", 9, "r20\xEF\xA3\xBDg20")
  @file_customer.writefield("2", 10, "r30\xEF\xA3\xBDg50")
  @file_customer.writefield("2", 11, "A01\xEF\xA3\xBDA02")
  @file_customer.write(3, "TAKAHASHI\xEF\xA3\xBERen\xEF\xA3\xBE1\xEF\xA3\xBE19770308")
  @file_customer.write(4, "TANAKA\xEF\xA3\xBEYuina\xEF\xA3\xBE2\xEF\xA3\xBE19780421")
  @file_customer.write(5, "ITO\xEF\xA3\xBEAoi\xEF\xA3\xBE2\xEF\xA3\xBE19790522")
end

