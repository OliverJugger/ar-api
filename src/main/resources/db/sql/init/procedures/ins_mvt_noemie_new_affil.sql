CREATE PROCEDURE ARTHUS.ins_mvt_noemie_new_affil (
   a_numporte     IN   NUMBER,
   a_idadhesion   IN   NUMBER,
   a_numindiv     IN   NUMBER,
   a_type         IN   NUMBER DEFAULT 1,
   a_mouvement    IN   VARCHAR2 DEFAULT 'C',
   a_debut        IN   DATE DEFAULT NULL,
   a_matorg       IN   VARCHAR2 DEFAULT NULL
)
/*===========================================================================*/
/* Procedure    : ins_mvt_noemie_new_affil.sql                               */
/* Domaine      : Santé                                                      */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 23/12/2015                                                 */
/* Description  : Création d'un mouvement noemie de nouvelle affiliation     */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
IS
   loc_idporte        NUMBER;
   loc_last_idporte   NUMBER;
BEGIN
/*
    pk_trace.p_ins_journal_adm ('ins_mvt_noemie_new_affil',
                              sid,
                              3,
                              'ins_mvt_noemie_new_affil a_matorg: '||a_matorg
                              ,SYSDATE,1
                             );
*/
   SELECT MAX (porte_adhesion.idporte)
     INTO loc_last_idporte
     FROM porte_adhesion,noemie
    WHERE porte_adhesion.numporte = a_numporte
     -- AND porte_adhesion.idadhesion = a_idadhesion
      AND noemie.idporte=porte_adhesion.idporte
      AND noemie.matorg=NVL(a_matorg,noemie.matorg)
      AND porte_adhesion.numindiv = a_numindiv
 --     AND porte_adhesion.transmis = 1
     -- AND porte_adhesion.mouvement != 'A'
      ;
/*
    pk_trace.p_ins_journal_adm ('ins_mvt_noemie_new_affil',
                              sid,
                              3,
                              'ins_mvt_noemie_new_affil a_fin: '||to_char(a_fin,'dd/mm/yyyy')
                              ,SYSDATE,2
                             );
*/
   IF (loc_last_idporte IS NOT NULL)
   THEN
      SELECT NVL (MAX (idporte), 0) + 1
        INTO loc_idporte
        FROM porte_adhesion;

      INSERT INTO porte_adhesion
                  (idporte, numporte, numindiv, idadhesion, numremise,
                   transmis, TYPE, debut, mouvement, fin)
         SELECT loc_idporte, numporte, numindiv, a_idadhesion, 0, 2, a_type,
                a_debut, a_mouvement, null
           FROM porte_adhesion
          WHERE idporte = loc_last_idporte;
/*
    pk_trace.p_ins_journal_adm ('ins_mvt_noemie_new_affil',
                              sid,
                              3,
                              'ins_mvt_noemie_new_affil insert1: '||a_matorg
                              ,SYSDATE,3
                             );
*/
      INSERT INTO noemie
                  (idporte, numporte, numindiv, numassu, idadhesion,
                   numremise, numsoc, numorg, orgbase, caisse, centre, matorg, natur,
                   debut, mouvement, fin, datnais, rang, cless, nom, prenom,
                   nomjf, type_contrat, creation, maj, datnais_regime)
         SELECT loc_idporte, numporte, numindiv, numassu, a_idadhesion, 0,
                numsoc, numorg, orgbase, caisse, centre, matorg, natur, a_debut,
                a_mouvement, null, datnais, rang, cless, nom,
                prenom, nomjf, type_contrat, TRUNC (SYSDATE), TRUNC (SYSDATE),
                datnais_regime
           FROM noemie
          WHERE idporte = loc_last_idporte;
/*
    pk_trace.p_ins_journal_adm ('ins_mvt_noemie_new_affil',
                              sid,
                              3,
                              'ins_mvt_noemie_new_affil insert2: '||a_matorg
                              ,SYSDATE,4
                             );
*/
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;  
END;
/
