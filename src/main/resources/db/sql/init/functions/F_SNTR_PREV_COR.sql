CREATE FUNCTION ARTHUS.F_SNTR_PREV_COR (a_NatCor IN NUMBER) RETURN NUMBER
AS
/*---------------------------------------------------------------------------*/
/*  FONCTION                                                                 */
/* Nom          :  F_SNTR_PREV_COR                                           */
/* Type         :  Public                                                    */
/* Description  :  Transcodification du code NAT_CORRES en DEST_COURRIER     */
/* Entree       :  a_NatCor,nature de correspondant                          */
/* Retour       :  Renvoi le code du type de destinataire                    */
/*===========================================================================*/
/* Evolution    : Pour Capra demande de pièces prévoyance                    */
/* Auteur       : ABO                                                        */
/* Date         : 28/07/2014                                                 */
/* Commentaire  : ajout du bénéficiaire                                      */
/*===========================================================================*/
  i_Result NUMBER;
BEGIN

  CASE a_NatCor -- LIBELLE.MNEMO='DEST_COURRIER' = 'ROLE'+'DEST_TYPE' (LBLE_EXT !)
  WHEN 0 THEN i_Result := 0; -- Personne
  WHEN 1 THEN i_Result := 3; -- Souscripteur
  WHEN 2 THEN i_Result := 5; -- Organisme Assureur
  WHEN 3 THEN i_Result := 15;-- Adhérent => assuré
  WHEN 4 THEN i_Result := 15;-- Bénéficiaire
  WHEN 6 THEN i_Result := 6;-- Médecin
  ELSE i_Result := NULL;
  END CASE;

  RETURN (i_Result);
EXCEPTION
   WHEN OTHERS THEN RETURN -1;
END;
