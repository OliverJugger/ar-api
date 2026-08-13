CREATE FUNCTION ARTHUS.F_COORDONNE_CONTACT (P_numindiv IN INDIVIDU.NUMINDIV%TYPE,P_NATURE IN CONTACT.NATURE%TYPE, P_TYPE IN CONTACT.NATURE%TYPE)
RETURN VARCHAR2
AS
/*=========================================================================
Fonction     : F_EMAIL_CONTACT
Domaine      : tout
Version      : V1.0
Auteur       : SDA, FNI
Création     : 17/04/2012
Description  : fonction permettant de ramener l'email d'un individu
               a partir du numéro de l'individu et du type
               ( 1) : Téléphone
               ( 2) : Mobile
               ( 3) : télécopie
               ( 4) : mail
               ( 5) : site web
==========================================================================
Evolution    : FNI 26/08/2014 Ajout du type en entrée
Auteur       :
Date         :
Commentaire  :
==========================================================================
Correction   :
==========================================================================*/
loc_ref_ext CONTACT.COORDONNEE%TYPE;

BEGIN

 SELECT trim(trim(BOTH CHR(9) FROM trim(BOTH CHR(10) FROM trim(BOTH CHR(13) FROM COORDONNEE))))
 INTO loc_ref_ext
 FROM CONTACT
 WHERE  numindiv = P_numindiv
 AND NATURE=P_NATURE
 AND TYPE = P_TYPE
 AND FLAG='O';

 RETURN loc_ref_ext;

EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;
END F_COORDONNE_CONTACT;
