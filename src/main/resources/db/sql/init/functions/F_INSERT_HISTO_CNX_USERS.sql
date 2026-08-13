CREATE function ARTHUS.F_INSERT_HISTO_CNX_USERS(a_action IN NUMBER)
  RETURN NUMBER
IS
/*===========================================================================*/
/* Procedure    : P_INSERT_HISTO_CNX_USERS.sql                               */
/* Domaine      : Prestation santé                                           */
/* Version      : V1.0                                                       */
/* Auteur       : SDA                                                        */
/* Création     : 15/10/2012                                                 */
/* Description  : insertion dans la table HISTO_CNX_USERS                    */
/*     a_action = 0 bouton valider                                           */
/*     a_action = 1 bouton quitter                                           */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
       loc_retour number;
       P_NOM varchar2(30);
       P_NUMUTIL NUMBER(3);
       P_NUMUID NUMBER(6);
       P_BASEUID NUMBER(6);
       P_IP varchar2(30);
       P_SID NUMBER(8);

BEGIN

 P_NUMUTIL := F_NUMUTIL();
 P_NOM := f_nomutil(P_NUMUTIL,1);

 SELECT NUMUID into P_NUMUID from UTILISATEURS where NUMUTIL = P_NUMUTIL;
 SELECT UID into P_BASEUID from DUAL;
 SELECT SID into P_SID FROM DUAL;
 P_IP := null;

 IF a_action = 0 THEN
   IF P_NUMUTIL > 0 THEN
        --insert
       INSERT INTO HISTO_CNX_USERS (NOM,NUMUTIL,NUMUID,BASEUID,IP,SID,DATE_DEB)
       VALUES (P_NOM,P_NUMUTIL,P_NUMUID,P_BASEUID,P_IP,P_SID,sysdate);
       loc_retour := 1;
   ELSE
       loc_retour := 0;
   END IF;
 ELSE
     UPDATE HISTO_CNX_USERS SET HISTO_CNX_USERS.DATE_FIN = sysdate WHERE HISTO_CNX_USERS.sid = P_SID;
     loc_retour := 1;
 END IF;
 commit;
 RETURN loc_retour;



EXCEPTION
     WHEN OTHERS THEN
          loc_retour := 0;
          RETURN loc_retour;
END;
