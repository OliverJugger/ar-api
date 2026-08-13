CREATE PROCEDURE ARTHUS.P_IMPORT_FILES_DSN_M0005555
IS
  cheminSource               varchar2(150);
  cheminCible                varchar2(150);
  o_remise              porte_remise.numremise%TYPE;
  L_lib_param           varchar2(250);
  G_nbre_lignes         Number := 1;
  o_erreur              VARCHAR2(200):=NULL;
  C_listFiles SYS_REFCURSOR;
  f_name  VARCHAR2(300);
  loc_file  VARCHAR2(300);

BEGIN
   SELECT directory_path INTO cheminSource
   FROM all_directories
   WHERE directory_name IN ('DSN_IN');
   SELECT directory_path INTO cheminCible
   FROM all_directories
   WHERE directory_name IN ('DSN_DONE');

   sys.PK_EXT_UTILS.ListFiles(cheminSource,C_listFiles);
   LOOP
   FETCH C_listFiles INTO f_name;
   EXIT WHEN C_listFiles%NOTFOUND;

    loc_file := REPLACE(f_name,UPPER(cheminSource));
    --dbms_output.put_line (loc_file) ;
    if loc_file  =  'FFSA_20200214_297638.txt' then

        
        PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'P_IMPORT_FILES_DSN_M0005555',
              I_session  => SID,
              I_niv_msg  => 1,
              I_msg_adm  => substr(f_name,1,132),
              I_idligne  => 1);
         
        
        -- Lancement de l'importation technique du fichier des affiliations
        ARTHUS.PK_IMPORT_AFFIL_DSN.IMPORT_AFFIL_DSN ( 20
                                                    , 1
                                                    , REPLACE(loc_file,'.txt','')
                                                    , sid
                                                    , 'AF05T'
                                                    , G_nbre_lignes
                                                    , o_remise); 
        
    end if ;
  END LOOP;
  CLOSE C_listFiles;
EXCEPTION
  WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'P_IMPORT_FILES_DSN_M0005555',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 1);
   CLOSE C_listFiles;
    ROLLBACK;
END P_IMPORT_FILES_DSN_M0005555;
/
