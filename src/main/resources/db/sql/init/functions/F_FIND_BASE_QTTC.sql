CREATE FUNCTION ARTHUS.F_FIND_BASE_QTTC (
   i_numfor                IN       AFFIL_PORTE_ADH.REFGARANTIE%TYPE
 , i_code_opt              IN       AFFIL_PORTE_ADH.CODE_OPT%TYPE
 , i_numquit               IN       AFFIL_PORTE_QTTC.NUMQUIT%TYPE
 , i_type_elt              IN       AFFIL_PORTE_QTTC_ELT.TYPE_ELT%TYPE
 , o_code_ano                 OUT   AFFIL_ANO.NUMANO%TYPE
)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_FIND_BASE_QTTC.sql                                       */
/* Domaine      : Cotisations                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 19/07/2016                                                 */
/* Description  : La fonction recherche la variable en fonction du type_elt  */
/*                garantie et facture de cotisations
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :   ABO 20/12/2021 revu des modalités de recherche           */
/*===========================================================================*/
  loc_idvariable      DEF_VARIABLE.IDVARIABLE%TYPE:=0;

BEGIN

    SELECT DISTINCT d.idvariable
    INTO loc_idvariable
    FROM qttc_global qttc,frml_prime_simple frml left outer join  GAR_PARAM_DETAIL det ON
          (frml.numfor = det.numfor AND frml.seq = det.seq)
    , def_variable  d
    , qttc_variable var
    WHERE F_GET_TRANSCO('DSN','BASE',d.nom_variable) = i_type_elt
    AND var.numfor  = i_numfor
    AND var.numquit = i_numquit
    AND var.numfor = frml.numfor
    AND var.idbase = d.idvariable
	  AND var.idbase = frml.base
	  AND var.numquit = qttc.numquit
	  AND qttc.debut BETWEEN frml.debut AND NVL(frml.fin, qttc.debut )
	  AND ((det.CODE_OPTION=i_code_opt OR det.LIB_OPTION=i_code_opt)
      OR (i_code_opt IS NULL AND det.CODE_OPTION IS NULL));

  o_code_ano:=0;

  RETURN (loc_idvariable);


EXCEPTION
  WHEN OTHERS THEN
    o_code_ano:=90;  -- Identification impossible de l’élt de calcul
    RETURN 0;
END F_FIND_BASE_QTTC ;
