CREATE FUNCTION ARTHUS.F_TOTQTTC_IND (
   i_numquit   IN       QTTC_GLOBAL.NUMQUIT%TYPE,
   i_statut    IN       NUMBER DEFAULT NULL
)
   RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_TOTQTTC_IND.sql                                          */
/* Domaine      : Cotisations                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 03/08/2016                                                 */
/* Description  : paramètre: le numéro de quittance                          */
/*              : Cette fonction recherche dans qttc_global la période de la */
/*              : quittance puis par jointure somme mt_base de la table      */
/*              : affil_porte_qttc_ind sur période et numquit identique      */
/*              : Elle permet de calculer le montant total de cotisation sur */
/*              : la période contractuelle                                   */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/

  loc_sum_mt_base       affil_porte_qttc_indiv.mt_base%TYPE:=NULL;

BEGIN

  SELECT SUM(api.mt_base)
    INTO loc_sum_mt_base
    FROM qttc_global qg
       , affil_porte_qttc apq
       , affil_porte_qttc_indiv api
   WHERE qg.numquit = i_numquit
    AND apq.numquit = qg.numquit
     AND apq.numremise = api.numremise
     AND apq.numporte = api.numporte
     AND apq.numligne = api.numligne
     AND api.num_qttc = apq.num_qttc
     AND apq.deb_base BETWEEN qg.debut and NVL(qg.fin,qg.debut) -- sur la période
	 AND apq.statut = NVL(i_statut,apq.statut)
     AND apq.statut NOT IN(6,0);



  RETURN (loc_sum_mt_base);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (0);
  
END F_TOTQTTC_IND ;
