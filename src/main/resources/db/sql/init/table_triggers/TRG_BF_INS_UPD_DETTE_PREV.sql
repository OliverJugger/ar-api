CREATE TRIGGER ARTHUS.TRG_BF_INS_UPD_DETTE_PREV
BEFORE INSERT OR UPDATE ON DETTE_PREV
FOR EACH ROW
/*===========================================================================*/
/* Trigger:     : TRG_BF_INS_UPD_DETTE_PREV.sql                              */
/* Domaine      : Tresorerie                                        ..       */
/* Version      : V1.0                                                       */
/* Auteur       : XHU                                                        */
/* Création     : 20/12/2010                                                 */
/* Description  : A chaque modification de la table, mise à jour des donnees */
/*              : d audit : DATEMAJ, USERMAJ,DATECREA,USERCREA               */
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
  IF INSERTING THEN
     :new.DATEMAJ := SYSDATE;
     :new.USERMAJ := F_NUMUTIL;
     :new.DATECREA := SYSDATE;
     :new.USERCREA := F_NUMUTIL;
  ELSIF UPDATING THEN
     :new.DATEMAJ := SYSDATE;
     :new.USERMAJ := F_NUMUTIL;
  END IF;
END;