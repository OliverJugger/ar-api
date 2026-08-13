CREATE FUNCTION ARTHUS.F_NUMGAR_REFCIE(a_numgar in number)
RETURN CONTRAT_REF.REFCIE%TYPE
IS
/*============================================================================*/
/* Fonction     : F_NUMGAR_REFCIE                                             */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 15/04/2013                                                  */
/* Description  : fonction qui recherche la référence du contrat              */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

loc_refcie contrat_ref.refcie%TYPE:=NULL;

BEGIN

  SELECT DISTINCT REFCIE
    INTO loc_refcie
    FROM contrat_ref
   WHERE numgar = a_numgar;

RETURN(loc_refcie);

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
