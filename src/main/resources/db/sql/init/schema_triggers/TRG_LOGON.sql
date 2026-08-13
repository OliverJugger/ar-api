CREATE OR REPLACE TRIGGER ARTHUS."TRG_LOGON"
AFTER logon ON DATABASE
BEGIN
 
EXECUTE IMMEDIATE 'alter session set nls_date_format=''DD-MON-RRRR''';
 
EXECUTE IMMEDIATE 'alter session set nls_date_language=''AMERICAN''';
 
EXECUTE IMMEDIATE 'alter session set nls_numeric_characters=''. ''';
 
END trg_logon;