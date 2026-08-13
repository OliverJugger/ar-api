CREATE PROCEDURE ARTHUS.INS_CARTE_TPE (
   I_numgar      IN  contrat_ref.numgar%TYPE,
   I_code_lettre IN  param_tiers_payant.code_lettre%TYPE,
   I_numporte    IN  porte_contrat.numporte%TYPE
)
IS

/*============================================================================*/
/* PROCEDURE    : INS_CARTE_TPE.sql                                           */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : 16/12/2011                                                  */
/* Description  : Modification de la carte TP en fonction du code lettre      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/

  loc_idparam_tp param_demande_tp.idparam_tp%TYPE;
  loc_idparam_base param_tiers_payant.idparam_tp%TYPE;
BEGIN

  SELECT max(idparam_tp)+1
  INTO loc_idparam_tp
  FROM param_demande_tp;

  SELECT idparam_tp
  INTO loc_idparam_base
  FROM param_tiers_payant
  WHERE code_lettre= I_code_lettre
  AND numporte = I_numporte
  AND numgar = 0;

 --création de la carte
  INSERT INTO param_tiers_payant
  SELECT loc_idparam_tp, I_numporte,I_numgar, type_carte, mode_exp,
        numdest,code_lettre, period,calcul,famille,organisme,
        centre,renouv, type_poch, garantie,debiteur_aphp, NUMAMC,
        promoteur
  FROM   param_tiers_payant
  WHERE  numporte = I_numporte --carte TPE
  AND    numgar =0 --toujours 0
  AND    idparam_tp = loc_idparam_base;--code du modèle de carte

  --rattachement des dommaines
  INSERT INTO param_demande_tp
  SELECT loc_idparam_tp,ordre, domaine,circuit, regle, renvoi
  FROM   param_demande_tp
  WHERE  idparam_tp = loc_idparam_base;--code carte

  --rattachement à toutes les garanties
  DELETE FROM gar_param_tp WHERE numgar = I_numgar;
  INSERT INTO gar_param_tp
         ( numfor, idparam_tp, numgar, idparam_base )
  VALUES (0, loc_idparam_tp, I_numgar, loc_idparam_base);


EXCEPTION
   WHEN OTHERS
   THEN dbms_output.put_line('Erreur : '||SQLERRM);
      NULL;
END;
/
