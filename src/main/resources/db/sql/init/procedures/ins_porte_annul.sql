CREATE PROCEDURE ARTHUS.ins_porte_annul (
   a_numporte     IN   NUMBER,
   a_idadhesion   IN   NUMBER,
   a_numindiv     IN   NUMBER,
   a_type         IN   NUMBER DEFAULT 8,
   a_mouvement    IN   VARCHAR2 DEFAULT 'A',
   a_fin          IN   DATE DEFAULT NULL,
   a_matorg       IN   VARCHAR2 DEFAULT NULL
)
/*===========================================================================*/
/* Procedure    : ins_porte_annul.sql                                        */
/* Domaine      : Santé                                                      */
/* Version      : V1.0                                                       */
/* Auteur       : ?                                                          */
/* Création     : ?                                                          */
/* Description  : Annulation d'un mouvement noemie                           */
/*===========================================================================*/
/* Evolution    : Gestion du double numéro de sécurité social                */
/* Auteur       : JBO                                                        */
/* Date         : 26/11/2013                                                 */
/* Commentaire  : Ajout du cartouche                                         */
/*===========================================================================*/
/* Correction   : jbo / 24/08/2016 / ???   (commit pha pour correction)      */
/* Correction   : pha / 24/08/2016 / M0005013                                */
/*===========================================================================*/
IS
   loc_idporte        NUMBER;
   loc_last_idporte   NUMBER;
BEGIN
/*
    pk_trace.p_ins_journal_adm ('ins_porte_annul',
                              sid,
                              3,
                              'ins_porte_annul a_matorg: '||a_matorg
                              ,SYSDATE,1
                             );
*/
   SELECT MAX (porte_adhesion.idporte)
     INTO loc_last_idporte
     FROM porte_adhesion,noemie
    WHERE porte_adhesion.numporte = a_numporte
      AND porte_adhesion.idadhesion = a_idadhesion
      AND noemie.idporte=porte_adhesion.idporte
      AND noemie.matorg=NVL(a_matorg,noemie.matorg)
      AND porte_adhesion.numindiv = a_numindiv
 --     AND porte_adhesion.transmis = 1
      AND porte_adhesion.mouvement != 'A';
/*
    pk_trace.p_ins_journal_adm ('ins_porte_annul',
                              sid,
                              3,
                              'ins_porte_annul a_fin: '||to_char(a_fin,'dd/mm/yyyy')
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
                debut, a_mouvement,
                DECODE (a_type, 12, a_fin, NVL (a_fin, fin))
           FROM porte_adhesion
          WHERE idporte = loc_last_idporte
            AND NOT(f_type_porte(a_numporte) = 4 AND TO_CHAR(debut, 'YYYY') <> TO_CHAR(DECODE (a_type, 12, a_fin, NVL (a_fin, fin)), 'YYYY'));
                -- ne pas insérer pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin
/*
    pk_trace.p_ins_journal_adm ('ins_porte_annul',
                              sid,
                              3,
                              'ins_porte_annul insert1: '||a_matorg
                              ,SYSDATE,3
                             );
*/
      INSERT INTO noemie
                  (idporte, numporte, numindiv, numassu, idadhesion,
                   numremise, numsoc, numorg, orgbase, caisse, centre, matorg, natur,
                   debut, mouvement, fin, datnais, rang, cless, nom, prenom,
                   nomjf, type_contrat, creation, maj, datnais_regime)
         SELECT loc_idporte, numporte, numindiv, numassu, a_idadhesion, 0,
                numsoc, numorg, orgbase, caisse, centre, matorg, natur, debut,
                a_mouvement, NVL (a_fin, fin), datnais, rang, cless, nom,
                prenom, nomjf, type_contrat, TRUNC (SYSDATE), TRUNC (SYSDATE),
                datnais_regime
           FROM noemie
          WHERE idporte = loc_last_idporte;
/*
    pk_trace.p_ins_journal_adm ('ins_porte_annul',
                              sid,
                              3,
                              'ins_porte_annul insert2: '||a_matorg
                              ,SYSDATE,4
                             );
*/
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
END;
/
