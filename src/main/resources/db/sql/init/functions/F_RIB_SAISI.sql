CREATE FUNCTION ARTHUS.F_RIB_SAISI ( i_type      IN RIB.TYPE%TYPE
                                       , i_nature    IN RIB.NATURE%TYPE
                                       , i_codpays   IN RIB.CODPAYS%TYPE
                                       , i_clef_iban IN RIB.CLEF_IBAN%TYPE
                                       , i_bban      IN RIB.BBAN%TYPE
                                       , i_bic       IN RIB.BIC%TYPE)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_RIB_SAISI.sql                                            */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 09/10/2012                                                 */
/* Description  : Permet de valider la cohérence de la structure d un rib    */
/*                normalisé(SEPA)                                            */
/* Entree       : i_type                                                     */
/*                i_nature                                                   */
/*                i_codpays                                                  */
/*                i_clef_iban                                                */
/*                i_bban                                                     */
/*                i_bic                                                      */
/* Retour       : 1 si le RIB est valide, Code erreur Arthus si RIB invalide */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_Nom            PAYS.NOM%TYPE:=NULL;
  loc_NbCarBBAN      PAYS.NBCARBBAN%TYPE:=NULL;
  loc_Pref_IBAN      PAYS.PREF_IBAN%TYPE:=NULL;
  loc_CodeISO        PAYS.PREF_IBAN%TYPE:=NULL;
  loc_valide         NUMBER:=0;
BEGIN

  -- Récupère les informations sur la validité d un rib normailisé pour un code pays
  SELECT NOM
       , NbCarBBAN
       , Pref_IBAN
       , CodeISO
    INTO loc_Nom
       , loc_NbCarBBAN
       , loc_Pref_IBAN
       , loc_CodeISO
    FROM PAYS
   WHERE CodPays=i_codpays;

  IF i_nature=2 THEN -- Rib normalisé

    IF i_clef_iban IS NOT NULL AND i_bban IS NOT NULL THEN
      IF loc_NbCarBBAN IS NOT NULL -- Controler la longueur saisie du BBAN suivant la longueur
      AND loc_NbCarBBAN > 0        -- définie sur le pays (si une longeur est renseignée)
      AND LENGTH(i_bban) != loc_NbCarBBAN THEN
        loc_valide:=1257;
      ELSE
        --P_CHECK_DEC_IBAN
        loc_valide:=0;
      END IF;
    END IF;

  ELSE
    loc_valide:=0;
  END IF;

   RETURN loc_valide;
EXCEPTION
  WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
    RETURN 1255;
  WHEN OTHERS THEN
    RETURN SQLERRM;
END F_RIB_SAISI;
