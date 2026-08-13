CREATE FUNCTION ARTHUS."F_SEL_INTERLOC_PARAM_OU_DEFAUT"(
         i_numindiv IN INTERLOCUTEUR.NUMINDIV%TYPE, -- NÂ° de la societe
         i_entite    IN CORRESPONDANT.ENTITE%TYPE,    -- NÂ° du sinistre
         i_codope    IN INTERLOCUTEUR.OPE_CRRR%TYPE)    -- NÂ° codope
  RETURN NUMBER                                   -- NÂ° d'interlocuteur  (INTERLOCUTEUR.INTERLOCUTEUR)
  AS
/*===========================================================================*/
/* Fonction     : F_SEL_INTERLOC_PARAM_OU_DEFAUT.sql                         */
/* Domaine      : 			                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : CLI                                                        */
/* Création     : ???                                                        */
/* Description  : fonction qui raméne l'interlocuteur parmétré sur un        */
/*                sinistre donné ou a defaut l'interlocuteur valide pour un  */
/*                type d'opération courrier(i_codope),  ou l'interlocuteur   */
/*                  toute opération si il existe 							 */
/*===========================================================================*/
/*===========================================================================*/
/* Correction   														     */
/*===========================================================================*/
  loc_retour NUMBER DEFAULT 0;

BEGIN

    IF (F_SEL_INTERLOCUTEUR(i_numindiv,i_entite)<>0) THEN
      loc_retour := F_SEL_INTERLOCUTEUR(i_numindiv,i_entite); --on retourne d'abord l'interlocuteur paramétré sur le sinistre
    ELSIF (f_sel_interlocuteur_defaut(i_numindiv,i_codope)<>0)THEN
      loc_retour := F_SEL_INTERLOCUTEUR_DEFAUT(i_numindiv,i_codope); -- sinon on chercher un interlocuteur par default valide
    END IF;
    RETURN loc_retour;
EXCEPTION
    WHEN OTHERS THEN
      RETURN loc_retour;

END F_SEL_INTERLOC_PARAM_OU_DEFAUT;
