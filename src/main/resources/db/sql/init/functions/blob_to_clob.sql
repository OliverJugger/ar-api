CREATE FUNCTION ARTHUS.blob_to_clob (p_data  IN  BLOB)
  RETURN CLOB
-- -----------------------------------------------------------------------------------
-- File Name     httpsoracle-base.comdbamiscellaneousblob_to_clob.sql
-- Author        Tim Hall
-- Description   Converts a BLOB to a CLOB.
-- Last Modified 26122016
-- -----------------------------------------------------------------------------------

is
l_clob         clob;
      l_dest_offsset integer := 1;
      l_src_offsset  integer := 1;
      l_lang_context integer := dbms_lob.default_lang_ctx;
      l_warning      integer;

   begin

      if p_data is null then
         return null;
      end if;

      dbms_lob.createTemporary(lob_loc => l_clob
                              ,cache   => false);

      dbms_lob.converttoclob(dest_lob     => l_clob
                            ,src_blob     => p_data
                            ,amount       => dbms_lob.lobmaxsize
                            ,dest_offset  => l_dest_offsset
                            ,src_offset   => l_src_offsset
                            ,blob_csid    => dbms_lob.default_csid
                            ,lang_context => l_lang_context
                            ,warning      => l_warning);

      return l_clob;
END;
