CREATE PROCEDURE ARTHUS.P_IMPORT_VIREMENTS_AUTO(o_erreur IN OUT VARCHAR2)
AS
  cheminSource               varchar2(150);
  cheminCible                varchar2(150);

  o_remise              porte_remise.numremise%TYPE;
  L_lib_param           varchar2(250);
  G_nbre_lignes         Number := 1;
  --o_erreur              VARCHAR2(200):=NULL;
  loc_tot_erreur number :=0;
  C_listFiles SYS_REFCURSOR;
  f_name  VARCHAR2(300);
  loc_file  VARCHAR2(300);
  loc_nb_file number :=0;
  -- variables paramétres pour lancer l'intégration technique

  I_REPERTOIRE VARCHAR2(200) :='VIR_IN';
  I_FICHIER VARCHAR2(200);
  I_PORTE NUMBER;
  I_ECHANGE NUMBER;
  I_SESSION NUMBER;
  I_NATURE NUMBER;
  I_TRAITEMENT VARCHAR2(32);
  I_IDLIGNE NUMBER;
  Message_rapport VARCHAR2(2000):= '';
  I_WARNING       VARCHAR2(2000):= '';

BEGIN
     PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_VIREMENTS_AUTO',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'Début traitement import virements',
          I_idligne  => 1);

   SELECT directory_path INTO cheminSource
   FROM all_directories
   WHERE directory_name IN (I_REPERTOIRE);

   sys.PK_EXT_UTILS.ListFiles(cheminSource,C_listFiles);
   LOOP
       FETCH C_listFiles INTO f_name;
       EXIT WHEN C_listFiles%NOTFOUND;

        loc_file := REPLACE(f_name,UPPER(cheminSource));

        I_FICHIER := loc_file;
        I_PORTE := 26;
        I_ECHANGE := 10;
        I_SESSION := sid;
        I_NATURE := 6;
        I_TRAITEMENT := 'VR16T';
        I_IDLIGNE := 1;
        O_ERREUR := null;
      PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'P_IMPORT_VIREMENTS_AUTO',
              I_session  => SID,
              I_niv_msg  => 1,
              I_msg_adm  => 'Fichier importé :'|| f_name,
              I_idligne  => 2);
        PK_IMPORT_VIREMENT.IMPORTVIREMENT(  I_REPERTOIRE => I_REPERTOIRE,
                                            I_FICHIER    => I_FICHIER,
                                            I_PORTE      => I_PORTE,
                                            I_ECHANGE    => I_ECHANGE,
                                            I_SESSION    => I_SESSION,
                                            I_NATURE     => I_NATURE,
                                            I_TRAITEMENT => I_TRAITEMENT,
                                            I_IDLIGNE    => I_IDLIGNE,
                                            O_REMISE     => O_REMISE,
                                            O_ERREUR     => O_ERREUR
                                        );

        IF o_erreur IS NOT NULL THEN
            loc_tot_erreur:= loc_tot_erreur+1;
        ELSE
            I_TRAITEMENT := 'VR18T';
            I_IDLIGNE := 1;
            O_ERREUR := NULL;
            PK_IMPORT_VIREMENT.P_GestionVIREMENT ( O_REMISE
                                                 , I_PORTE
                                                 , NULL
                                                 , 1
                                                 , 0
                                                 , SID
                                                 , 'VR18T'
                                                 , 1
                                                 , O_ERREUR
                                                 , I_WARNING);
        END IF;
        IF TRIM(O_ERREUR)IS NOT NULL THEN
          Message_rapport := Message_rapport ||chr(10)||chr(13)||'- Fichier : '||I_FICHIER|| ', Numéro de remise :'||O_REMISE||', Message :['||O_ERREUR||']';
        ELSE
          Message_rapport := Message_rapport ||chr(10)||chr(13)||'- Fichier : '||I_FICHIER|| ', Numéro de remise :'||O_REMISE||', Import des virements réussi, '||I_WARNING;
        END IF;
        loc_nb_file := loc_nb_file+1;
  END LOOP;
  CLOSE C_listFiles;
  IF loc_tot_erreur > 0 THEN -- envoi d'un mail uniquement si il y a eu un soucis lors de l'integration d'un des fichiers
    o_erreur := '1'; --'Erreur de l''import technique de la remise';
  elsif loc_nb_file =0 THEN          --M0005826 RKO
   Message_rapport:='Aucun fichier importé';
  else
   o_erreur :='0'; -- 'Import technique terminé avec succés';
  END IF;

  PK_IMPORT_VIREMENT.P_SEND_RAPPORT_ENVOI_MAIL(sysdate, Message_rapport, loc_nb_file );

EXCEPTION
  WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'P_IMPORT_VIREMENTS_AUTO',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 1);
   CLOSE C_listFiles;
    ROLLBACK;
END P_IMPORT_VIREMENTS_AUTO;
/
