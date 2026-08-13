CREATE OR REPLACE package ARTHUS.PK_WS_FRONT_SANTECLAIR
as
/*=========================================================================
PAckage      : PK_WS_FRONT_SANTECLAIR
Domaine      : webservice
Version      : V1.0
Auteur       : SDA
Création     : 19/05/2014
Description  :
==========================================================================
Evolution    :
Auteur       :
Date         :
Commentaire  :
==========================================================================
Correction   :
==========================================================================*/
FUNCTION F_SC_IDENTIFICATION(
  P_FLUX_SC VARCHAR2
) RETURN VARCHAR2;

FUNCTION F_SC_CALCUL(
  P_FLUX_SC VARCHAR2
) RETURN VARCHAR2;

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_WS_FRONT_SANTECLAIR as


/**************FUNCTION F_SC_IDENTIFICATION*************************/
FUNCTION F_SC_IDENTIFICATION (
         P_FLUX_SC VARCHAR2
     ) RETURN VARCHAR2
     IS
       REP_F_SC_IDENTIFICATION VARCHAR2(32000);
     BEGIN

       REP_F_SC_IDENTIFICATION := PK_WS_BACK_SANTECLAIR.F_RET_SC_IDENDIFICATION(P_FLUX_SC);

       RETURN REP_F_SC_IDENTIFICATION;
     EXCEPTION
       WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_SC_IDENTIFICATION',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(sqlerrm,1,132),
          I_idligne  => 2);
          RETURN 'ERREUR ENTREE FLUX IDENTIFICATION 1';
END F_SC_IDENTIFICATION;


/**************FUNCTION F_SC_IDENTIFICATION*************************/
FUNCTION F_SC_CALCUL (
         P_FLUX_SC VARCHAR2
     ) RETURN VARCHAR2
     IS
       REP_F_SC_CALCUL VARCHAR2(32000);
     BEGIN
       REP_F_SC_CALCUL := PK_WS_BACK_SANTECLAIR.F_RET_SC_CALCUL(P_FLUX_SC);
       RETURN REP_F_SC_CALCUL;
     EXCEPTION
       WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_SC_IDENTIFICATION',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(sqlerrm,1,132),
          I_idligne  => 2);
          RETURN 'ERREUR ENTREE FLUX CALCUL 1';
END F_SC_CALCUL;

END PK_WS_FRONT_SANTECLAIR;
/
