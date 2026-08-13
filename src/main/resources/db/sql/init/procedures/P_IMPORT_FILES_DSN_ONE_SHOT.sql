CREATE PROCEDURE ARTHUS.P_IMPORT_FILES_DSN_ONE_SHOT
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
  
  CURSOR c_remise
      IS
  SELECT DISTINCT a.NUMREMISE, a.numporte
    FROM  PORTE_REMISE pr
        , AFFIL_PORTE a
   WHERE pr.numporte = 20
     AND a.NUMREMISE= pr.NUMREMISE
     AND pr.numporte = a.numporte
     AND a.etat=2
     AND pr.numremise IN(625 ,658 ,1724 ,1731 ,3197, 5036 )
    ORDER BY a.NUMREMISE ASC;
  
BEGIN
  /*
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
    
    
    --
    -- Lancement de l'importation du fichier des affiliations
    --
    --
    ARTHUS.PK_IMPORT_AFFIL_DSN.IMPORT_AFFIL_DSN ( 20
                                                , 1 
                                                , REPLACE(loc_file,'.txt','')
                                                , sid
                                                , 'AF05T'
                                                , G_nbre_lignes
                                                , o_remise);
  END LOOP;
  CLOSE C_listFiles;
     */
  --
  -- Lancement de l identification fonctionnelles des affiliations
  --
  FOR rec_remise IN c_remise LOOP 
    ARTHUS.PK_GEST_AFFIL.P_GestAffiliation ( rec_remise.numremise
                                           , rec_remise.numporte
                                           , 7
                                           , 7
                                           , SID
                                           , 'AF04T'
                                           , G_nbre_lignes
                                           , NULL
                                           , 0
                                           , o_erreur) ;
  END LOOP;

  
EXCEPTION
  WHEN OTHERS THEN
   CLOSE C_listFiles;
    ROLLBACK;
END P_IMPORT_FILES_DSN_ONE_SHOT;
/
