CREATE PROCEDURE ARTHUS.P_IMPORT_FILES_DSN
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
  loc_debut DATE;
  loc_fin   DATE;

  CURSOR c_remise
    IS
    SELECT DISTINCT adh.NUMREMISE, adh.numporte
    FROM AFFIL_PORTE_ADH adh
     , PORTE_REMISE pr
    WHERE TRUNC(pr.DATEREMISE) >= TRUNC(SYSDATE-7)  -- MUR M0006485
    AND pr.NUMREMISE = adh.NUMREMISE
    AND pr.NUMPORTE = adh.NUMPORTE
    AND pr.numporte = 20
    and exists (select 1 from affil_porte ap where ap.numremise = pr.numremise and ap.numporte = pr.numporte and ap.etat = 2) -- MUR M0006485
    ORDER BY adh.NUMREMISE ASC;




  -- MUR M0006485
  loc_heure number;

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


    PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => substr(f_name,1,132),
          I_idligne  => 1);


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
    -- MUR M0006485
    SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    IF loc_heure >=22 THEN
      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'fin traitement delai depassé ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1);
      EXIT;  --dernier traitement à 22h
    END IF ;

 END LOOP;
  CLOSE C_listFiles;

  PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'fin integration technique ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1);

  --
  -- Lancement de l identification fonctionnelles des affiliations, l'intégration doit se faire qu'au 15 du mois
  --
  FOR rec_remise IN c_remise LOOP
    PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'debut integ fonct remise ' || rec_remise.numremise ,
          I_idligne  => 1);

    -- MUR M0006485
    SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    IF loc_heure >=22 THEN
      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'fin traitement delai depassé ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1);
      EXIT;  --dernier traitement à 22h
    END IF ;

    ARTHUS.PK_GEST_AFFIL.P_GestAffiliation ( rec_remise.numremise
                                           , rec_remise.numporte
                                           , 7
                                           , 7
                                           , SID
                                           , 'AF04T'
                                           , G_nbre_lignes
                                           , NULL
                                           , NULL
                                           , o_erreur) ;

  END LOOP;


   --  Constitution du bdx CRM et génération fichier
   PK_EXPORT_CRM_DSN.P_GENERER_CRM_DSN_AUTO();
EXCEPTION
  WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'P_IMPORT_FILES_DSN',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 1);
   CLOSE C_listFiles;
    ROLLBACK;
END P_IMPORT_FILES_DSN;
/
