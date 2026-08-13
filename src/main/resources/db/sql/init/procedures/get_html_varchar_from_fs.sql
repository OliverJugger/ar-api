CREATE PROCEDURE ARTHUS.get_html_varchar_from_fs (p_dir  IN VARCHAR2,
                                                 p_file IN VARCHAR2,
                                                 p_clob IN OUT NOCOPY CLOB)
AS
  l_bfile BFILE;
  l_step  PLS_INTEGER := 12000;
BEGIN
  l_bfile := BFILENAME(p_dir, p_file);
  DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);

  FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(l_bfile) - 1 )/l_step) LOOP
    p_clob := p_clob || UTL_RAW.cast_to_varchar2(DBMS_LOB.substr(l_bfile, l_step, i * l_step + 1));
  END LOOP;

  DBMS_LOB.fileclose(l_bfile);
END;
/
