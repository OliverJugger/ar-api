CREATE FUNCTION ARTHUS.F_FIND_STATUT_CNTRT ( i_numquit   IN       QTTC_GLOBAL.NUMQUIT%TYPE
                             )
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_FIND_STATUT_CNTRT.sql                                    */
/* Domaine      : Cotisations                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 04/08/2016                                                 */
/* Description  : Cette fonction a pour objectif d’afficher par contrat le   */
/*                statut d’intégration de la cotisation. Le statut est porté */
/*                par cotisation individuelle, pour définir le statut pour   */
/*                toute la quittance les règles de gestion doivent être      */
/*                respectées                                                 */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_statut    AFFIL_PORTE_QTTC.STATUT%TYPE:=NULL;


BEGIN

  -- Le statut quittance peut être égale :
          --15 intégré
		  -- 2 à intégrer
          --3 bloquée
          --5 identifié mais non ventilé
		  -- 6 hors période
          --7 intégré avec avertissement

  -- Si une quittance réunit plusieurs statut, on priorisera toujours le statut bloqué 3.
 /*SELECT NVL(MAX(aq.STATUT),0)
    INTO loc_statut
    FROM AFFIL_PORTE_QTTC aq
   WHERE aq.numquit =  i_numquit
     AND aq.STATUT=3
       ;
  -- Sinon rechercher présence statut 5
  IF loc_statut = 0 THEN
    SELECT NVL(MAX(aq.STATUT),0)
      INTO loc_statut
      FROM AFFIL_PORTE_QTTC aq
     WHERE aq.numquit =  i_numquit
       AND aq.STATUT=5;
  ELSE  RETURN loc_statut;
  END IF;
  -- Sinon rechercher présence statut 7
  IF loc_statut = 0 THEN
    SELECT NVL(MAX(aq.STATUT),0)
      INTO loc_statut
      FROM AFFIL_PORTE_QTTC aq
     WHERE aq.numquit =  i_numquit
       AND aq.STATUT=7;
  ELSE  RETURN loc_statut;
  END IF;*/
  SELECT NVL(MIN(aq.STATUT),0)
    INTO loc_statut
    FROM AFFIL_PORTE_QTTC aq
   WHERE aq.numquit =  i_numquit
     AND aq.STATUT NOT IN (6,9);
  -- Sinon rechercher présence statut 6 et 9
  IF loc_statut = 0 THEN
    SELECT NVL(MAX(aq.STATUT),0)
      INTO loc_statut
      FROM AFFIL_PORTE_QTTC aq
     WHERE aq.numquit =  i_numquit
        AND aq.STATUT NOT IN (6,9);
  ELSE  RETURN loc_statut;
  END IF;
  IF loc_statut = 0 THEN RETURN 2; --a intégrer
  ELSE
   RETURN loc_statut;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_FIND_STATUT_CNTRT ;
