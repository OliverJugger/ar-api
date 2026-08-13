CREATE FUNCTION ARTHUS.F_SENS_LIBELLE(P_mnemo IN LIBELLE.MNEMO%TYPE
                      , P_code  IN LIBELLE.CODE%TYPE)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_SENS_LIBELLE                                             */
/* Domaine      : Paramétrage                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 16/11/2011                                                 */
/* Description  : fonction permettant de ramener le sens de la table libelle */
/*                a partir de son mnemo et de son code                       */
/*===========================================================================*/
/* Evolution    : CCAM: Ajout de la table LIBELLE_BIS                        */
/* Auteur       : JBO                                                        */
/* Date         : 26/05/2014                                                 */
/* Commentaire  : Fait avec ABO                                              */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_sens LIBELLE.SENS%TYPE;
BEGIN
  SELECT sens
    INTO loc_sens
    FROM LIBELLE
   WHERE MNEMO = P_mnemo
     AND CODE = P_code;

  RETURN loc_sens;

EXCEPTION
  WHEN OTHERS THEN
   BEGIN
   SELECT sens
    INTO loc_sens
    FROM LIBELLE_BIS
   WHERE MNEMO = P_mnemo
     AND CODE = P_code;

   RETURN loc_sens;

   EXCEPTION
    WHEN OTHERS THEN
	RETURN NULL;
  END;

END F_SENS_LIBELLE;
