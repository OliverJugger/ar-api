CREATE PROCEDURE ARTHUS."CHARGE_COTISATION" (
   a_numquit      IN       NUMBER,
   a_date_debut   IN       DATE,
   a_date_fin     IN       DATE,
   t_donnee       OUT      pk_texte.donnee
)
IS
/*============================================================================*/
/* PACKAGE      : CHARGE_COTISATION.sql                                       */
/* Domaine      : Courrier                                                    */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : ???                                                         */
/* Description  : Données cotisations par quittance courrier                  */
/*============================================================================*/
/* Evolution    : Ajout du mandat SEPA                                        */
/* Auteur       : ABO                                                         */
/* Date         : 06/12/2013                                                  */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : PHA 09/04/2018 M0005564: Ajout mregl = 5 virement           */
/*============================================================================*/
   a_fin     DATE;
   l_mregl   BINARY_INTEGER;
-- Variable de reconnaissance SCCS
-- @(#)charge_cotisation.sql  1.6 Charge les donnees de la table qttc_global   01/10/09
BEGIN
   BEGIN
      SELECT mregl
        INTO l_mregl
        FROM facture
       WHERE codope = 4 AND numfact = a_numquit;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   SELECT MAX (qttc_global.fin)
     INTO a_fin
     FROM qttc_global
    WHERE (qttc_global.numgar, qttc_global.numindiv) IN (
                                                   SELECT a.numgar,
                                                          a.numindiv
                                                     FROM qttc_global a
                                                    WHERE a.numquit =
                                                                     a_numquit)
      AND NVL (l_mregl, qttc_global.prelev) = 2;

   SELECT qttc_global.numquit, qttc_global.numquerable,
          d2e (qttc_global.datemis), d2e (qttc_global.debut),
          d2e (qttc_global.fin),
          TO_CHAR (qttc_global.mt_net_d, '9G999G999D99') || ' '
          || mone.libelle,
          TO_CHAR (qttc_global.mt_ttc_d, '9G999G999D99') || ' '
          || mone.libelle,
             TO_CHAR (qttc_global.mt_affec_d, '9G999G999D99')
          || ' '
          || mone.libelle,
             TO_CHAR (f_qttc_du_d (qttc_global.idadhesion, qttc_global.debut),
                      '9G999G999D99'
                     )
          || ' '
          || mone.libelle,
             TO_CHAR ((  (  qttc_global.mt_ttc_d
                          - NVL (qttc_global.mt_affec_d, 0)
                         )
                       + f_qttc_du_d (qttc_global.idadhesion,
                                      qttc_global.debut
                                     )
                      ),
                      '9G999G999D99'
                     )
          || ' '
          || mone.libelle,
          TO_CHAR ((qttc_global.mt_ttc - NVL (qttc_global.mt_affec, 0)),
                   '9999999990.90'
                  ),                                                -- en euro
          TO_CHAR (  (qttc_global.mt_ttc - NVL (qttc_global.mt_affec, 0))
                   + f_qttc_du (qttc_global.idadhesion, qttc_global.debut),
                   '9999999990.90'
                  )                                                 -- en euro
     INTO t_donnee (1), t_donnee (2),
          t_donnee (3), t_donnee (4),
          t_donnee (5),
          t_donnee (6),
          t_donnee (7),
          t_donnee (8),
          t_donnee (9),
          t_donnee (10),
          t_donnee (11),
          t_donnee (12)
     FROM qttc_global, mone
    WHERE qttc_global.numquit = a_numquit
      AND mone.codmon = qttc_global.monnaie_d
      AND NVL (l_mregl, qttc_global.prelev) IN ( 1 , 5 )
   UNION
   SELECT   a_numquit, a.numquerable, TO_CHAR (a.datemis, 'dd/mm/yyyy'),
            TO_CHAR (a.debut, 'dd/mm/yyyy'), TO_CHAR (a_fin, 'dd/mm/yyyy'),
               TO_CHAR (SUM (qttc_global.mt_net_d), '9G999G999D99')
            || ' '
            || mone.libelle,
               TO_CHAR (SUM (qttc_global.mt_ttc_d), '9G999G999D99')
            || ' '
            || mone.libelle,
               TO_CHAR (SUM (qttc_global.mt_affec_d), '9G999G999D99')
            || ' '
            || mone.libelle,
               TO_CHAR (f_qttc_du_d (a.idadhesion, a.debut), '9G999G999D99')
            || ' '
            || mone.libelle,
               TO_CHAR ((  SUM (  qttc_global.mt_ttc_d
                                - NVL (qttc_global.mt_affec_d, 0)
                               )
                         + f_qttc_du_d (a.idadhesion, a.debut)
                        ),
                        '9G999G999D99'
                       )
            || ' '
            || mone.libelle,
            TO_CHAR (SUM (qttc_global.mt_ttc - NVL (qttc_global.mt_affec, 0)),
                     '9999999990.90'
                    ),                                              -- en euro
            TO_CHAR (  SUM (qttc_global.mt_ttc - NVL (qttc_global.mt_affec, 0))
                     + f_qttc_du (a.idadhesion, a.debut),
                     '9999999990.90'
                    )                                               -- en euro
       FROM qttc_global, qttc_global a, mone
      WHERE qttc_global.prelev = 2
        AND NVL (l_mregl, a.prelev) = 2
        AND qttc_global.numgar = a.numgar
        AND qttc_global.numindiv = a.numindiv
        AND qttc_global.idadhesion = a.idadhesion
        AND a.numquit = a_numquit
        AND mone.codmon = qttc_global.monnaie_d
        AND qttc_global.debut BETWEEN a.debut AND a_fin
   GROUP BY a.numquerable,
            TO_CHAR (a.datemis, 'dd/mm/yyyy'),
            TO_CHAR (a.debut, 'dd/mm/yyyy'),
            TO_CHAR (a_fin, 'dd/mm/yyyy'),
            a.idadhesion,
            a.debut,
            mone.libelle;
	BEGIN		
		SELECT histo_querable.mandat --, histo_querable.mandat_maitr-- SEPA 17/03/2014 : ajout mandat maitre dans COTIS(19)
		INTO t_donnee (18) --, t_donnee (19)                          -- SEPA 17/03/2014 : ajout mandat maitre dans COTIS(19)
		FROM histo_querable 
		WHERE idhistoquerable = 
		(SELECT MAX(idhistoquerable) FROM qttc_global, histo_querable 
		WHERE qttc_global.numquit = a_numquit
		AND histo_querable.numgar = qttc_global.numgar 
		AND histo_querable.idadhesion = qttc_global.idadhesion 
		AND histo_querable.numquerable = qttc_global.numquerable
		AND histo_querable.creation <= a_date_debut);
	EXCEPTION
		WHEN  NO_DATA_FOUND THEN  t_donnee (18) := '/';
		WHEN  OTHERS THEN  t_donnee (18) := ' ';
	END;
END;
/
