CREATE OR REPLACE PACKAGE ARTHUS.PK_PURGE_ARTHUS
AS
/*============================================================================*/
/* Package      : P_PURGE_ARTHUS.sql                                          */
/* Domaine      : Purge de l'historique des appels WebServices                */
/*                et de journal_adm                                           */
/* Version      : V1.0                                                        */
/* Auteur       : BCO/PBO                                                     */
/* Création     : 27/02/2021                                                  */
/* Description  :                                                             */
/*============================================================================*/
PROCEDURE P_PURGE_ARTHUS ( i_date  IN DATE
                          ,i_dateheurefin IN DATE DEFAULT NULL);

-- Purge des tables WebServices
PROCEDURE P_PURGE_WS ( i_date IN DATE );

-- Purge de la table journal_adm
PROCEDURE P_PURGE_JOURNAL_ADM ( i_date IN DATE );

--Purge des tables stock_entite, stock_entite_p, et stock_fact_sp
PROCEDURE P_PURGE_RECURR_ROC ( i_date IN DATE );

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PURGE_ARTHUS AS
/*============================================================================*/
/* Package      : P_PURGE_ARTHUS.sql                                          */
/* Domaine      : Purge de l'historique des appels WebServices                */
/*                et de journal_adm                                           */
/* Version      : V1.0                                                        */
/* Auteur       : BCO/PBO                                                     */
/* Création     : 27/02/2021                                                  */
/* Description  : Paramètres en entrée: 2                                     */
/*                  i_ date: obligatoire / date pivot pour la purge           */
/*                  i_dateheurefin: facultatif / défaut: 4h                   */
/*                           duree max prévue du traitement                   */
/*                Délais de conservation avant purges:                        */
/*                  - Appels WebService: 2 ans glissants                      */
/*                  - Journal_adm: 2 mois glissants                           */
/*============================================================================*/
PROCEDURE P_PURGE_ARTHUS (i_date          IN  DATE -- date obligatoire
                         ,i_dateheurefin  IN  DATE DEFAULT NULL -- Durée de traitement / facultatif
                         )
IS

  loc_idlig JOURNAL_ADM.IDLIGNE%TYPE := 0;
  loc_dateheurefin DATE;

BEGIN

  /* Traitement */
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Debut traitement: i_date= ' || TO_CHAR(i_date,'YYYY/MM/DD HH24:MI:SS') ,
                               I_idligne  => loc_idlig);

  /* Contrôle des paramètres d'entrée */
  IF i_date IS NULL THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'DatePivot purge non renseignée. Arrêt traitement',
                                 I_idligne  => loc_idlig );
    RETURN; -- arret traitement
  END IF;

  loc_dateheurefin := i_dateheurefin;

  -- Durée traitement => 4h par defaut
  IF loc_dateheurefin IS NULL THEN
    loc_dateheurefin := SYSDATE + NUMTODSINTERVAL (4,'HOUR');
  END IF;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'loc_dateheurefin= ' || TO_CHAR(loc_dateheurefin,'YYYY/MM/DD HH24:MI:SS') ,
                               I_idligne  => loc_idlig);



  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Arrêt traitement limité à ' || TO_CHAR(loc_dateheurefin, 'DD/MM/YYYY HH24:MI:SS') ||'.',
                               I_idligne  => loc_idlig );

  -- Purge des tables WebServices
  P_PURGE_WS ( i_date );
  COMMIT;

  IF sysdate > loc_dateheurefin THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Arrêt forcé temps limite dépassé: ' || TO_CHAR(loc_dateheurefin, 'DD/MM/YYYY HH24:MI:SS') ||'.',
                               I_idligne  => loc_idlig );
    RETURN;
  END IF;

  -- Purge de la table Joural_adm
  P_PURGE_JOURNAL_ADM ( i_date );
  COMMIT;

  IF sysdate > loc_dateheurefin THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Arrêt forcé temps limite dépassé: ' || TO_CHAR(loc_dateheurefin, 'DD/MM/YYYY HH24:MI:SS') ||'.',
                               I_idligne  => loc_idlig );
    RETURN;
  END IF;


  --Purge des tables stock_entite, stock_entite_p, et stock_fact_sp
  P_PURGE_RECURR_ROC ( i_date => sysdate );
  COMMIT;

  IF sysdate > loc_dateheurefin THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Arrêt forcé temps limite dépassé: ' || TO_CHAR(loc_dateheurefin, 'DD/MM/YYYY HH24:MI:SS') ||'.',
                               I_idligne  => loc_idlig );
    RETURN;
  END IF;


  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Fin Traitement',
                               I_idligne  => loc_idlig);

EXCEPTION
  WHEN OTHERS THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'Purge stoppée',
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_ARTHUS:'||SUBSTR(sqlerrm,1,132),
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_ARTHUS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_ARTHUS:'||SUBSTR(sqlerrm,133,132),
                                 I_idligne  => loc_idlig);
    RETURN;

END;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_PURGE_WS                                                */
/* Type         :  Privé                                                     */
/* Description  :  Purge des appels WebService sur 2 années glissantes       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_PURGE_WS ( i_date IN DATE )
IS
  loc_idlig JOURNAL_ADM.IDLIGNE%TYPE := 0;
  loc_id_flux FLUX.ID_FLUX%TYPE;

BEGIN

  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Début traitement idate:' || TO_CHAR(i_date,'YYYY/MM/DD HH24:MI:SS') ,
                               I_idligne  => loc_idlig);


  -- id_flux de plus de 2 années glissantes
  SELECT MIN(id_flux) INTO loc_id_flux
  FROM flux
  WHERE dat_maj >= ADD_MONTHS(i_date,-24);

  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'id_flux maximum:' || loc_id_flux ,
                               I_idligne  => loc_idlig);


  DELETE HISTO_FLUX_WS_SC
  WHERE ID_FLUX_SC < loc_id_flux ;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes HISTO_FLUX_WS_SC supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_01
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_01 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_02
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_02 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_03
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_03 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_04
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_04 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_05
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_05 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_06
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_06 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_07
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_07 supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_08_ITELIS
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_08_ITELIS supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_09_ITELIS
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_09_ITELIS supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);


  DELETE XML_04_10_ITELIS
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_10_ITELIS supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_11_ITELIS
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_11_ITELIS supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_12_ITELIS
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_12_ITELIS supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_12_NET
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_12_NET supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE XML_04_12_WS_WEB_MAJ
  WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes XML_04_12_WS_WEB_MAJ supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE FLUX WHERE ID_FLUX < loc_id_flux;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes FLUX supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);



  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Fin traitement',
                               I_idligne  => loc_idlig);


EXCEPTION
  WHEN OTHERS THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'Purge stoppée',
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_WS:'||SUBSTR(sqlerrm,1,132),
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_WS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_WS:'||SUBSTR(sqlerrm,133,132),
                                 I_idligne  => loc_idlig);

END P_PURGE_WS;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_PURGE_JOURNAL_ADM                                       */
/* Type         :  Privé                                                     */
/* Description  :  Purge de journal_adm sur 2 mois glissants                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_PURGE_JOURNAL_ADM ( i_date IN DATE )
IS

  loc_idlig JOURNAL_ADM.IDLIGNE%TYPE := 0;

  BEGIN
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_JOURNAL_ADM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Début traitement',
                               I_idligne  => loc_idlig);


  DELETE JOURNAL_ADM
  WHERE DATE_ADM < (SELECT min(date_adm) FROM journal_adm where date_adm >= ADD_MONTHS(i_date,-2)) ; -- avant 2 mois glissants
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_JOURNAL_ADM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes JOURNAL_ADM supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_JOURNAL_ADM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Fin traitement',
                               I_idligne  => loc_idlig);

EXCEPTION
  WHEN OTHERS THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_JOURNAL_ADM',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'Purge stoppée',
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_JOURNAL_ADM',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_JOURNAL_ADM:'||SUBSTR(sqlerrm,1,132),
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_JOURNAL_ADM',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_JOURNAL_ADM:'||SUBSTR(sqlerrm,133,132),
                                 I_idligne  => loc_idlig);
  RETURN;

END P_PURGE_JOURNAL_ADM;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_PURGE_RECURR_ROC                                        */
/* Type         :  Privé                                                     */
/* Description  :  Purge recurrente des tables STOCK_ENTITE, STOCK_ENTITE_P
                     et STOCK_FACT_SP dans le cadre du projet ROC            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_PURGE_RECURR_ROC ( i_date IN DATE )
IS
  loc_idlig JOURNAL_ADM.IDLIGNE%TYPE := 0;
  loc_id_flux FLUX.ID_FLUX%TYPE;

BEGIN

  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Début traitement idate:' || TO_CHAR(i_date,'YYYY/MM/DD HH24:MI:SS'),
                               I_idligne  => loc_idlig);


  DELETE STOCK_ENTITE
  WHERE numremise in (select numremise from porte_remise where dateremise <i_date-15);

  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes STOCK_ENTITE supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE STOCK_ENTITE_P ;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes STOCK_ENTITE_P supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  DELETE STOCK_FACT_SP
  WHERE numremise in (select numremise from porte_remise where nature=3
                    and trunc(dateremise) < trunc(add_months(i_date,-24)))
  AND trunc(creation) < trunc(add_months(i_date,-24))
  ;
  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'lignes STOCK_FACT_SP supprimées:' || TO_CHAR(SQL%ROWCOUNT),
                               I_idligne  => loc_idlig);

  loc_idlig := loc_idlig + 1 ;
  PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Fin traitement',
                               I_idligne  => loc_idlig);


EXCEPTION
  WHEN OTHERS THEN
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_RECURR_ROC: Purge stoppée',
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_RECURR_ROC:'||SUBSTR(sqlerrm,1,132),
                                 I_idligne  => loc_idlig);
    loc_idlig := loc_idlig + 1 ;
    PK_TRACE.P_INS_JOURNAL_ADM ( I_nom_traitement => 'P_PURGE_RECURR_ROC',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_PURGE_RECURR_ROC:'||SUBSTR(sqlerrm,133,132),
                                 I_idligne  => loc_idlig);

END P_PURGE_RECURR_ROC;

END PK_PURGE_ARTHUS;
/
