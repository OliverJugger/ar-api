CREATE FUNCTION ARTHUS.F_VAL_VAR_ALL (
        P_clef IN Binary_integer,
        P_idvar IN Binary_integer,
        P_deb IN DATE default sysdate)
RETURN VARCHAR2
AS
/*===========================================================================*/
/* Fonction     : F_VAL_VAR_ALL                                              */
/* Domaine      : Paramétrage                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO-ABO                                                    */
/* Création     : 11/10/2011                                                 */
/* Description  : fonction d'interrogation de la table val_variable pour n'  */
/*                importe quel domaine fonction provenant de                 */
/*                TRG_BF_INS_SINSITRE_PORTE, elle ne prend pas en compte les */
/*                spécialités médicales.                                     */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_etendue  Binary_integer;
  CURSOR C_val_var IS
    SELECT  valeur
    FROM  val_variable
    WHERE  valide = 'O'
    AND  P_deb BETWEEN debut and nvl( fin, P_deb )
    and  idvariable + 0 = P_idvar
    AND  clef = P_clef
    AND  etendue = loc_etendue
    ORDER BY debut Desc;

  Rec_C_val_var C_val_var%ROWTYPE;

  BEGIN

  SELECT  etendue
  INTO  loc_etendue
  FROM  def_variable
  WHERE  idvariable = P_idvar;

   OPEN C_val_var;
    FETCH C_val_var into Rec_C_val_var;
    IF C_val_var%FOUND THEN
      CLOSE C_val_var;
      RETURN Rec_C_val_var.valeur;
    ELSE
      CLOSE C_val_var;
      RETURN null;
    END IF;


END F_VAL_VAR_ALL;
