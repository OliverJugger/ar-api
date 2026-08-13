CREATE FUNCTION ARTHUS.F_FIND_VAR (P_nomvar IN def_variable.nom_variable%TYPE)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_FIND_VAR                                                 */
/* Domaine      : Paramétrage                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO-ABO                                                    */
/* Création     : 11/10/2011                                                 */
/* Description  : fonction d'interrogation d une donnee utilisateur          */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_idvariable def_variable.idvariable%TYPE;
BEGIN
    SELECT idvariable INTO loc_idvariable
    FROM DEF_VARIABLE
    WHERE nom_variable =P_nomvar ;

    RETURN loc_idvariable;

EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END F_FIND_VAR;
