CREATE TRIGGER ARTHUS."TRG_BF_UPD_ENCAISMT"
BEFORE UPDATE ON ENCAISMT
FOR EACH ROW
/*===========================================================================*/
/* Trigger:     : TRG_AF_UPD_ENCAISMT.sql                                    */
/* Domaine      : Tresorerie                                        ..       */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 13/12/2010                                                 */
/* Description  : A chaque modification de la table, mise à jour des donnees */
/*              : d audit : MODIFICATION, MODIFICATEUR (M0001171)            */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
BEGIN
  :new.MODIFICATION := SYSDATE;
  :new.MODIFICATEUR  := F_NUMUTIL;
END;