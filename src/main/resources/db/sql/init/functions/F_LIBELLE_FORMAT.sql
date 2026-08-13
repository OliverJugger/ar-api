CREATE FUNCTION ARTHUS.F_LIBELLE_FORMAT (P_mnemo IN LIBELLE.MNEMO%TYPE
                                , P_code  IN LIBELLE.CODE%TYPE)
RETURN LIBELLE.LIBELLE%TYPE
AS
/*===========================================================================*/
/* Fonction     : F_LIBELLE_FORMAT                                           */
/* Domaine      : Paramétrage                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 21/05/2013                                                 */
/* Description  : fonction permettant de ramener l extension d un fichier    */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_libelle LIBELLE.LIBELLE%TYPE:=NULL;
BEGIN


  SELECT l.libelle
    INTO loc_libelle
    FROM LIBELLE l
   WHERE l.MNEMO =P_mnemo
     AND l.CODE=P_code;

  RETURN loc_libelle;

EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END F_LIBELLE_FORMAT;
