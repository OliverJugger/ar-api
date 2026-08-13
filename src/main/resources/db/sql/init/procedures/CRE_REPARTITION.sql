CREATE PROCEDURE ARTHUS.CRE_REPARTITION (
   a_idadhesion   IN   NUMBER,
   a_numfor       IN   NUMBER,
   a_nosin        IN   VARCHAR2,
   a_debut        IN   DATE
)
IS
/*===========================================================================*/
/* Procedure    : CRE_REPARTITION.sql                                        */
/* Domaine      : Prestation prévoaynce                                      */
/* Version      : V1.0                                                       */
/* Auteur       : ?                                                          */
/* Création     : ?                                                          */
/* Description  : Création pour une garantie et un sinistre d'une repartition*/
/*              : et des bénéficiaires par défaut paramétré                  */
/*===========================================================================*/
/* Evolution    : Instruction systématique des bénéficiaires / nouveaux types*/
/* Auteur       : ABO                                                        */
/* Date         : 06/09/2013                                                 */
/* Commentaire  : Evolutions réalisées pour Capra                            */
/*===========================================================================*/
/* Evolution    : Ajout de la colonne GEST_CALC et ajout de la table GAR dans*/
/*                l insertion dans repartition avec jointure sur le numfor   */
/* Auteur       : JBO                                                        */
/* Date         : 02/10/2013                                                 */
/* Commentaire  : Mise en place du module du calcul de prestations prévoyance*/
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/

   loc_idrepartition   repartition.idrepartition%TYPE;
   loc_numindiv        individu.numindiv%TYPE;
   dummy               NUMBER;
BEGIN

  BEGIN
    SELECT numindiv INTO loc_numindiv
    FROM sin_prev
    WHERE nosin = a_nosin;

    SELECT idrepartition INTO loc_idrepartition
    FROM repartition
    WHERE nosin = a_nosin
    AND idadhesion = a_idadhesion
    AND numfor = a_numfor;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        BEGIN
           SELECT idrepartition.NEXTVAL
             INTO loc_idrepartition
             FROM DUAL;

              INSERT INTO repartition
                          (idrepartition, idadhesion, numfor, nosin, type_calc,periode,gest_calc)
                 SELECT loc_idrepartition, a_idadhesion, a_numfor, a_nosin,
                        gar_prev.type_calc, gar_prev.type_period, gar.gest_calc
                   FROM gar_prev,gar
                  WHERE gar_prev.numfor = a_numfor
                    AND gar.numfor=gar_prev.numfor;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
        END;
  END;

  INSERT INTO repartition_bene
           (idrepartition, numbene, debut, etat, type_dest,
            numbene_dest, exclu_dde_pj, irrevocable)
  SELECT loc_idrepartition, beneficiaire.numbene, a_debut, 1,
         gar.type_dest,
         DECODE (gar.type_dest,
                 1, beneficiaire.numbene,
                 2, contrat.numcli,
                 3, adhe_cntrt.numadhe,
                 NVL(pk_prev.SEL_CORRES_BY_TYPE_DEST(a_nosin,15,gar.type_dest, NULL),beneficiaire.numbene)
                ),
         'N', 'N'
    FROM gar, contrat, adhe_cntrt, beneficiaire
   WHERE gar.numfor = a_numfor
     AND adhe_cntrt.numgar = contrat.numgar
     AND adhe_cntrt.idadhesion = beneficiaire.idadhesion
     AND beneficiaire.numfor = a_numfor
     AND beneficiaire.idadhesion = a_idadhesion
     AND beneficiaire.numindiv = loc_numindiv
     AND beneficiaire.valide='O';

EXCEPTION
  WHEN OTHERS THEN NULL;

END CRE_REPARTITION;
/
