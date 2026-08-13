CREATE PROCEDURE ARTHUS.P_DUP_RG (p_numprod_cib   IN NUMBER,
                                      p_numprod_src   IN NUMBER)
/*===========================================================================*/
/* Procedure    : P_DUP_RG.sql                                               */
/* Domaine      : Santé                                                      */
/* Auteur       : Arthus                                                     */
/* Création     : 08/11                                                      */
/* Description  : Duplication des règles générales d'un produit source       */
/*                        vers un produit cible                              */
/*===========================================================================*/
IS
    l_regl_source PARAM_PRODUIT%ROWTYPE;
BEGIN
  --suppression du paramétrage des règles générales existant sur le produit cible
	DELETE param_produit WHERE numprod=p_numprod_cib;
  --recuperation du paramétrage des règles générales du produit source
	SELECT *INTO l_regl_source FROM PARAM_PRODUIT WHERE numprod=p_numprod_src;
	l_regl_source.NUMPROD :=p_numprod_cib;--on recupère le produit cible
	--Duplication du paramétrage du produit source vers le produit cible.
  INSERT INTO PARAM_PRODUIT(NUMPROD,
													  TYPGAR,
													  TYPE_CONTRAT,
													  NAT_CALC,
													  TYPE_TERME,
													  TYPEQUIT,
													  TYPE_CALC,
													  MODE_CALCUL,
													  FRACT,
													  ARRONDI,
													  MREGL,
													  ECHE_ANNIV,
													  REVISION,
													  DELAI,
													  CT_RESP,
													  TYPE_ECHE)
	VALUES (l_regl_source.NUMPROD,
				  l_regl_source.TYPGAR,
				  l_regl_source.TYPE_CONTRAT,
				  l_regl_source.NAT_CALC,
				  l_regl_source.TYPE_TERME,
				  l_regl_source.TYPEQUIT,
				  l_regl_source.TYPE_CALC,
				  l_regl_source.MODE_CALCUL,
				  l_regl_source.FRACT,
				  l_regl_source.ARRONDI,
				  l_regl_source.MREGL,
				  l_regl_source.ECHE_ANNIV,
				  l_regl_source.REVISION,
				  l_regl_source.DELAI,
				  l_regl_source.CT_RESP,
				  l_regl_source.TYPE_ECHE);
END P_DUP_RG;
/
