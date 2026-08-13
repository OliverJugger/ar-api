CREATE PROCEDURE ARTHUS.P_IMPORT_FILES_DSN_INT
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
  
   loc_heure number;
  loc_min   number;
  
  CURSOR c_remise
      IS
  SELECT DISTINCT af.NUMREMISE, af.numporte
    FROM AFFIL_FICHIER af
       , PORTE_REMISE pr
   WHERE af.datefic <= trunc(add_months(sysdate,-1),'MM')
     AND pr.NUMREMISE = af.NUMREMISE
     AND pr.NUMPORTE = af.NUMPORTE
     AND pr.numporte = 20
     AND af.nature =1 --uniquement DSN mensuelle
     AND EXISTS (
     select numligne FROM AFFIL_PORTE ap 
      WHERE ap.numremise = af.numremise 
      AND ap.numporte = af.numporte 
      AND ap.etat in (2)
      AND ap.entreprise = af.entreprise
      AND ap.etabli =af.etabli
      and Ap.Num_Ordre = af.num_ordre)
    ORDER BY af.NUMREMISE ASC;
  
BEGIN

   SELECT directory_path INTO cheminSource 
   FROM all_directories 
   WHERE directory_name IN ('DSN_IN');
   SELECT directory_path INTO cheminCible 
   FROM all_directories 
   WHERE directory_name IN ('DSN_DONE');

  
  -- Lancement de l identification fonctionnelles des affiliations, l'intégration doit se faire qu'au 15 du mois
  --
  FOR rec_remise IN c_remise LOOP 
    SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
    IF loc_heure >=23 AND loc_min>30 THEN
    EXIT;--dernier traitement à 23h30
    END IF;
    ARTHUS.PK_GEST_AFFIL.P_GestAffiliation ( rec_remise.numremise
                                           , rec_remise.numporte
                                           , 7
                                           , 7
                                           , SID
                                           , 'AF04T'
                                           , G_nbre_lignes
                                           , NULL
                                           , null
                                           , o_erreur) ;
    COMMIT;
  END LOOP;

  
EXCEPTION
  WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'P_IMPORT_FILES_DSN_INT',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 1);
   CLOSE C_listFiles;
    ROLLBACK;
END P_IMPORT_FILES_DSN_INT;
/
