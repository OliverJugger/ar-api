CREATE FUNCTION ARTHUS.F_TOTQTTC_IND_OUT (
   i_numgar   IN       affil_porte_adh.NUMGAR%TYPE,
   i_datefic  IN       DATE,
   i_debut    IN       DATE,
   i_fin      IN       DATE
)
   RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_TOTQTTC_IND_OUT.sql                                      */
/* Domaine      : Cotisations                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 03/08/2016                                                 */
/* Description  : paramètre: le numéro de quittance                          */
/*              : Cette fonction recherche dans qttc_global la période de la */
/*              : quittance puis par jointure somme mt_base de la table      */
/*              : affil_porte_qttc_ind sur période et numquit identique      */
/*              : Elle permet de calculer le montant total de cotisation hors*/
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
    FROM  affil_porte_adh adh
       , affil_porte_qttc apq
       , affil_porte_qttc_indiv api
   WHERE adh.numgar = i_numgar
     AND adh.numremise = api.numremise
     AND adh.numporte = api.numporte
     AND adh.numligne = api.numligne
     AND apq.numremise = api.numremise
     AND apq.numporte = api.numporte
     AND apq.numligne = api.numligne
     AND api.num_qttc = apq.num_qttc
     --AND apq.statut = 6
	 AND apq.deb_base NOT BETWEEN  i_debut AND i_fin;

  RETURN (loc_sum_mt_base);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (0);

END F_TOTQTTC_IND_OUT ;
