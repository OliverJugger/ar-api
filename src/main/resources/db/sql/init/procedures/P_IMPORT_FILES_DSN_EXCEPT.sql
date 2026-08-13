CREATE PROCEDURE ARTHUS.P_IMPORT_FILES_DSN_EXCEPT
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
  
  /*
  CURSOR c_remise
      IS
  SELECT DISTINCT adh.NUMREMISE, adh.numporte
    FROM AFFIL_PORTE_ADH adh
       , PORTE_REMISE pr
   WHERE (TRUNC(pr.DATEREMISE) = e2d('29/12/2017') or TRUNC(pr.DATEREMISE) = e2d('09/01/2018')  ) -- 29decembre2017 et 09 janvier 2018
     AND pr.NUMREMISE = adh.NUMREMISE
     AND pr.NUMPORTE = adh.NUMPORTE
     AND pr.numporte = 20
    ORDER BY adh.NUMREMISE ASC;
  */

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
    
    
    --
    -- Lancement de l'importation du fichier des affiliations
    --
    --
    dbms_output.put_line(loc_file) ;

    /*
    if loc_file in ( 'FFSA_20181101_198387.txt'
                    ,'FFSA_20181110_200386.txt'
                    ,'FFSA_20181114_201231.txt') then
    */
    if loc_file in ( 'FFSA_20181101_198387.txt') then
       dbms_output.put_line('trt fichier ' || loc_file) ;

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

  /* MUR ne pas traiter intégration fonctionelle
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
                                           , NULL   -- MUR cf prod
                                           , o_erreur) ;
  END LOOP;
  */

  
EXCEPTION
  WHEN OTHERS THEN
   CLOSE C_listFiles;
    ROLLBACK;
END P_IMPORT_FILES_DSN_EXCEPT;
/
