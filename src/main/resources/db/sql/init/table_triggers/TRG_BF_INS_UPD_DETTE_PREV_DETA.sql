CREATE TRIGGER ARTHUS.TRG_BF_INS_UPD_DETTE_PREV_DETA
BEFORE INSERT ON DETTE_PREV_DETAIL
FOR EACH ROW
/*===========================================================================*/
/* Trigger:     : TRG_BF_INS_UPD_DETTE_PREV_DETA                             */
/* Domaine      : Tresorerie                                        ..       */
/* Version      : V1.0                                                       */
/* Auteur       : XHU                                                        */
/* Création     : 28/12/2010                                                 */
/* Description  : A chaque modification de la table, mise à jour des donnees */
/*              : d audit : DATEMAJ, USERMAJ                                 */
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
      IF :new.numligne IS NULL THEN
         SELECT SEQ_NUMLIGNE.NEXTVAL
         INTO :new.numligne
         FROM DUAL;
      END IF;
      :new.DATEMAJ := SYSDATE;
      :new.USERMAJ := F_NUMUTIL;
      :new.DATECREA := SYSDATE;
      :new.USERCREA := F_NUMUTIL;
  ELSIF UPDATING THEN
      :new.DATEMAJ := SYSDATE;
      :new.USERMAJ := F_NUMUTIL;
  END IF;
END;