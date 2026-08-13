CREATE PROCEDURE ARTHUS."INS_VS" (
   a_idrepartition   IN   NUMBER,
   a_numbene         IN   NUMBER,
   a_numindiv_dest   IN   NUMBER,
   a_entite          IN   NUMBER,
   a_entite_ref      IN   NUMBER,
   a_type            IN   NUMBER,
   a_contexte        IN   NUMBER,
   a_numfor          IN   NUMBER default 0
)
IS
/*============================================================================*/
/* PROCEDURE    : INS_VS.sql                                                   */
/* Domaine      : Courrier                                                    */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : 2007                                                        */
/* Description  : Insertion selon parametrage d'une demande de piece          */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : NSO 25-06-2009 des cas 17 et 18                             */
/*              : ABO 06/06/2012M3144 piece de garantie: ajout du numfor      */
/*              : ABO 29/01/2020  groupe de garanties via  = v_gar_cntrt      */
/*              : ABO 27/07/2020  doublon de pieces contexte EA PREV          */
/*============================================================================*/
BEGIN
   BEGIN
    IF a_contexte IN (15, 16, 17, 18) AND a_idrepartition <>0 THEN
    --pour la prévoyance uniquement une mise à jour de la répartition est nécessaire pour les pièces créées avant instruction
    -- contexte particulier de l'extranet prev + ITT
      UPDATE pieces SET idrepartition = a_idrepartition
      WHERE contexte = a_contexte
      AND entite =a_entite
      AND numbene = a_numbene;
    END IF;


      INSERT INTO pieces
                  (contexte, entite, numfor, numbene, numindiv_dest,
                   idrepartition, nopiece, delai, period, bloc, dateenreg)
         SELECT DISTINCT a_contexte, a_entite, param_pieces.numfor,
                         a_numbene, a_numindiv_dest, a_idrepartition,
                         TO_NUMBER (param_pieces.nopiece),
                         param_pieces.delai, param_pieces.period,
                         param_pieces.bloc, TRUNC (SYSDATE)
                    FROM param_pieces
                   WHERE type_piece = a_contexte
                     AND entite = f_numgar_ref(a_entite_ref)
                     AND entite = f_numgar_ref(a_entite_ref)
                     AND (numfor = NVL(pk_qttc.f_sel_numfor (a_entite_ref, a_numfor ),0)
                       OR numfor IN (
                         SELECT pk_qttc.f_sel_numfor (numgar, numfor )
                         FROM v_gar_cntrt
                         WHERE numgar  = a_entite_ref
                         AND idgarantie = a_numfor))
                     AND contexte =
                            DECODE (a_contexte,
                                    3, 7,
                                    DECODE (a_type, 1, 7, 2)
                                   )
                     AND (   (    numfor IN (
                                     SELECT numfor
                                       FROM repartition
                                      WHERE valide = 'O'
                                        AND idrepartition = a_idrepartition)
                              AND a_contexte IN (15, 16, 17, 18)
                             )
                          OR (a_contexte NOT IN (15, 16, 17, 18))
                         )
                     AND (   (    a_contexte IN (15, 16, 17, 18)
                              AND NOT EXISTS (
                                     SELECT 1
                                       FROM pieces
                                      WHERE idrepartition = a_idrepartition
                                        AND numbene = a_numbene
                                        AND numindiv_dest = a_numindiv_dest
                                        AND nopiece =
                                               TO_NUMBER (param_pieces.nopiece)
                                        AND contexte = a_contexte
                                        AND entite = a_entite)
                             )
                          OR (a_contexte NOT IN (15, 16, 17, 18))
						 )
             AND NOT EXISTS (select idpiece FROM pieces
              WHERE contexte = a_contexte
              AND entite = a_entite AND nopiece = TO_NUMBER (param_pieces.nopiece)
              AND idrepartition = a_idrepartition
              AND numbene = a_numbene);
		 EXCEPTION
			WHEN NO_DATA_FOUND THEN NULL;

   END;
END;
/
