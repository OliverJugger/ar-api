CREATE PROCEDURE ARTHUS.ins_force_porte_annul (
   a_numporte     IN   NUMBER,
   a_numgar       IN   NUMBER,
   a_idadhesion   IN   NUMBER,
   a_numindiv     IN   NUMBER,
   a_type         IN   NUMBER DEFAULT 8,
   a_mouvement    IN   VARCHAR2 DEFAULT 'A',
   a_debut        IN   DATE DEFAULT NULL,
   a_fin          IN   DATE DEFAULT NULL,
   a_matorg       IN   VARCHAR2 DEFAULT NULL
)
/*===========================================================================*/
/* Procedure    : ins_force_porte_annul.sql                                  */
/* Domaine      : Santé                                                      */
/* Version      : V1.0                                                       */
/* Auteur       : PHA                                                        */
/* Création     : 18/11/2016                                                 */
/* Description  : Insertion fin d'un mouvement noemie sans mvt creation      */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
IS
   loc_idporte        NUMBER;
   loc_last_idporte   NUMBER;
BEGIN

   IF (loc_last_idporte IS NOT NULL)
   THEN
      SELECT NVL (MAX (idporte), 0) + 1
        INTO loc_idporte
        FROM porte_adhesion;

      INSERT INTO porte_adhesion
                  (idporte, numporte, numindiv, idadhesion, numremise,
                   transmis, TYPE, debut, mouvement, fin)
         SELECT loc_idporte, a_numporte, a_numindiv, a_idadhesion, 0, 2, a_type,
                a_debut, a_mouvement, a_fin
           FROM DUAL
          WHERE NOT(f_type_porte(a_numporte) = 4 AND TO_CHAR(a_debut, 'YYYY') <> TO_CHAR(a_fin, 'YYYY'));
                -- ne pas insérer pour les types de porte 4 si l'année de début ne correspond pas à l'année de fin

      INSERT INTO noemie
                  (idporte, numporte, numindiv, numassu, idadhesion,
                   numremise, numsoc, numorg,
                   orgbase, caisse, centre, matorg, natur,
                   debut, mouvement, fin, datnais, rang, cless, nom, prenom,
                   nomjf, type_contrat, creation, maj, datnais_regime)
         SELECT loc_idporte, a_numporte, numindiv, numassu, a_idadhesion, 0,
                contrat_ref.numinterm, contrat_ref.numorg,
                regime, caisse, guichetorg, matorg, natur, a_debut,
                a_mouvement, a_fin, datnais, rang, cless, nom,
                prenom, nomjf, '01', TRUNC (SYSDATE), TRUNC (SYSDATE),
                datnais_regime
           FROM individu, contrat_ref
           WHERE numindiv = a_numindiv
             AND contrat_ref.numgar_ref = pk_qttc.f_sel_numgar (a_numgar) ;


   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
END;
/
