CREATE FUNCTION ARTHUS.F_TOTQTTC_IN_OUT (
   i_numgar   IN       affil_porte_adh.NUMGAR%TYPE,
   i_datefic  IN       DATE,
   i_type     IN       NUMBER
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

  SELECT NVL(SUM(api.mt_base),0)
    INTO loc_sum_mt_base
    FROM  affil_porte_adh adh
       , affil_porte_qttc apq
       , affil_porte_qttc_indiv api
       , affil_fichier af
       , affil_porte ap
   WHERE adh.numgar = i_numgar
     AND adh.numremise = api.numremise
     AND adh.numporte = api.numporte
     AND adh.numligne = api.numligne
	 AND apq.ref_ext_cntrt = adh.ref_ext_cntrt
     AND apq.ref_ext_adh = adh.ref_ext_adh
     AND apq.numremise = api.numremise
     AND apq.numporte = api.numporte
     AND apq.numligne = api.numligne
     AND api.num_qttc = apq.num_qttc
     --AND apq.statut = 6
	 AND ((i_type = 1 AND apq.deb_base  BETWEEN   trunc(i_datefic,'Q') AND  (add_months(trunc(i_datefic,'Q'),3)-1))
	 OR( i_type = 2 AND apq.deb_base NOT BETWEEN  trunc(i_datefic,'Q') AND  (add_months(trunc(i_datefic,'Q'),3)-1)))
	 AND ap.numremise = adh.numremise
     AND ap.numporte = adh.numporte  
     AND ap.numligne = adh.numligne   
     AND ap.numremise = af.numremise 
     AND ap.numporte = af.numporte
     AND ap.entreprise = af.entreprise
     AND ap.etabli = af.etabli
     AND ap.num_ordre = af.num_ordre
     AND  af.datefic  BETWEEN   trunc(i_datefic,'Q') AND  add_months(trunc(i_datefic,'Q'),3)-1
	 AND af.num_annulante IS NULL
	 AND ap.etat <>4;
	
  RETURN (loc_sum_mt_base);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (0);
  
END F_TOTQTTC_IN_OUT ;
