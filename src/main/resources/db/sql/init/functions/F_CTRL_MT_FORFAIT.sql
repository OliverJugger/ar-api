CREATE FUNCTION ARTHUS.F_CTRL_MT_FORFAIT ( loc_type_elt             IN      AFFIL_PORTE_QTTC_ELT.type_elt%TYPE
                           , loc_mt_forfait           IN OUT  AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE
                           , loc_coeff                IN      NUMBER -- TODO  :  devons nous le mettre en place : besoin pour modulo
                           )
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_CTRL_MT_FORFAIT.sql                                      */
/* Domaine      : Cotisations                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 19/07/2016                                                 */
/* Description  : La fonction                                                */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_resulat    NUMBER:=NULL;
  loc_ano        NUMBER:=NULL;

BEGIN

  loc_resulat  := MOD(loc_mt_forfait,loc_coeff);
  IF loc_resulat <> 0 THEN
    loc_ano:=95; -- Montant forfaitaire incohérent
  ELSE
    loc_ano:=0; -- Montant forfaitaire correct
  END IF;

  RETURN (loc_ano);

EXCEPTION
  WHEN OTHERS THEN
    loc_ano:=96;  -- Montant forfaitaire inconnu
    RETURN loc_ano;
END F_CTRL_MT_FORFAIT ;
