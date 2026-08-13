CREATE PROCEDURE ARTHUS.INS_NOEMIE_MATORG (
   a_numporte     IN   NUMBER,
   a_numindiv     IN   NUMBER,
   a_idadhesion   IN   NUMBER,
   a_numgar       IN   NUMBER,
   a_debut        IN   DATE,
   a_fin          IN   DATE,
   a_mouvement    IN   VARCHAR2,
   a_type         IN   NUMBER,
   a_matorg       IN VARCHAR2
)
/*===========================================================================*/
/* Procedure    : INS_NOEMIE_MATORG.sql                                             */
/* Domaine      : Santé                                                      */
/* Version      : V1.0                                                       */
/* Auteur       : ?                                                          */
/* Création     : ?                                                          */
/* Description  : Création d'un mouvement noemie sur un numss donné          */
/* Auteur       : ABO                                                        */
/* Date         : 12/01/2021                                                 */
/*===========================================================================*/
IS
  loc_idporte      NUMBER;
  loc_type         NUMBER;
  loc_etat         NUMBER;
  loc_type_porte   NUMBER;
  loc_numassu      NUMBER;
  loc_matorg       VARCHAR2(30):=NULL;
  loc_matorg2      VARCHAR2(30):=NULL;

BEGIN


pk_trace.p_ins_journal_adm ('INS_NOEMIE_MATORG',
                          sid,
                          3,
                          'a_idadhesion: '||to_char(a_idadhesion)||',a_numindiv:'||to_char(a_numindiv)
                          ,SYSDATE,1
                         );

  BEGIN
     SELECT DISTINCT indvs.matorg,indvs.matorg2
       INTO loc_matorg,loc_matorg2
       FROM indvs
      WHERE indvs.numindiv = a_numindiv;
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        loc_etat := 6;
        loc_type := 20;
     WHEN TOO_MANY_ROWS
     THEN
        loc_etat := 6;
        loc_type := 20;
  END;


  SELECT NVL (MAX (idporte), 0) + 1
    INTO loc_idporte
    FROM porte_adhesion;

   /* Recherche ouvreur de droits */
   loc_type := a_type;
   loc_etat := 2;


  BEGIN
    SELECT DISTINCT numindiv
      INTO loc_numassu
      FROM individu
     WHERE matorg=a_matorg
       AND natur = 1;
      -- AND (typadr=0 OR typadr=1) ;
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        loc_numassu := NULL;
     WHEN TOO_MANY_ROWS
     THEN
        loc_numassu := NULL;
  END;

  INSERT INTO porte_adhesion
              (numporte, numindiv, debut, fin, mouvement, transmis,
               numremise, idadhesion, TYPE, idporte)
     SELECT a_numporte, a_numindiv, a_debut, a_fin, a_mouvement,
            loc_etat, 0, a_idadhesion, loc_type, loc_idporte
       FROM DUAL;

  IF a_matorg = loc_matorg THEN
    INSERT INTO noemie
                (idporte, numporte, numindiv, numassu, idadhesion,
                 numremise, numsoc, numorg, orgbase, caisse, centre, matorg, natur,
                 debut, mouvement, fin, datnais, rang, cless, nom, prenom,
                 nomjf, type_contrat, creation, maj, datnais_regime)
       SELECT loc_idporte, a_numporte, a_numindiv, NVL(loc_numassu,indvs.numassu),
              a_idadhesion, 0, contrat_ref.numinterm, contrat_ref.numorg,
              indvs.regime, indvs.caisse, indvs.guichetorg, loc_matorg, indvs.natur,
              a_debut, a_mouvement, a_fin, indvs.datnais, indvs.rang,
              indvs.cless, indvs.nom, indvs.prenom, indvs.nomjf, '01',
              TRUNC (SYSDATE), TRUNC (SYSDATE), indvs.datnais_regime
         FROM indvs, contrat_ref
        WHERE contrat_ref.numgar_ref = pk_qttc.f_sel_numgar (a_numgar)
          AND indvs.numindiv = a_numindiv;

  ELSIF a_matorg = loc_matorg2 THEN
    INSERT INTO noemie
                (idporte, numporte, numindiv, numassu, idadhesion,
                 numremise, numsoc, numorg, orgbase, caisse, centre, matorg, natur,
                 debut, mouvement, fin, datnais, rang, cless, nom, prenom,
                 nomjf, type_contrat, creation, maj, datnais_regime)
       SELECT loc_idporte, a_numporte, a_numindiv, NVL(loc_numassu,indvs.numassu),
              a_idadhesion, 0, contrat_ref.numinterm, contrat_ref.numorg,
              indvs.regime2, indvs.caisse2, indvs.guichetorg2, loc_matorg2, indvs.natur,
              a_debut, a_mouvement, a_fin, indvs.datnais, indvs.rang,
              indvs.cless2, indvs.nom, indvs.prenom, indvs.nomjf, '01',
              TRUNC (SYSDATE), TRUNC (SYSDATE), indvs.datnais_regime
         FROM indvs, contrat_ref
        WHERE contrat_ref.numgar_ref = pk_qttc.f_sel_numgar (a_numgar)
          AND indvs.numindiv = a_numindiv;

  END IF;

EXCEPTION
   WHEN OTHERS THEN
      pk_trace.p_ins_journal_adm ('INS_NOEMIE_MATORG',
                                sid,
                                3,
                                'WHEN OTHERS THEN: '||SUBSTR(SQLERRM,1,132)
                                ,SYSDATE,1
                               );
     NULL;
END INS_NOEMIE_MATORG;
/
