CREATE FUNCTION ARTHUS.F_REFEXT_FACTURE (P_numfact IN FACTURE.NUMFACT%TYPE, P_codope IN FACTURE.CODOPE%TYPE)
RETURN VARCHAR2
AS
/*===========================================================================*/
/* Fonction     : F_REFEXT_FACTURE                                           */
/* Domaine      : Trésorerie                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : ABO                                                        */
/* Création     : 03/07/2012                                                 */
/* Description  : fonction permettant de ramener la référence extérieure     */
/*                a partir du numéro de facture et du code opération         */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
loc_ref_ext facture.ref_ext%TYPE;

BEGIN
  SELECT ref_ext
    INTO loc_ref_ext
    FROM FACTURE
   WHERE NUMFACT = P_numfact
     AND CODOPE = P_codope;

  RETURN loc_ref_ext;

EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END F_REFEXT_FACTURE;
