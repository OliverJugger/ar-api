CREATE FUNCTION ARTHUS."F_BENE_RIB" (
   a_numindiv   IN   NUMBER,
   a_codope     IN   NUMBER,
   a_numgar     IN   NUMBER,
   a_dec_enc    IN   NUMBER,
   a_devise in number default null,
   a_date in date default sysdate
)
   RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_BENE_RIB.sql                                             */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ???                                                        */
/* Création     : 01/01/1990                                                 */
/* Description  : Recherche un rib valide pour une personne en fonction      */
/*              : du code de l'opération concernée, du numéro de contrat,    */
/*              : du sens de l'opération, de la devise et de la date de      */
/*              : validité, les deux derniers paramètres étant optionnels.   */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : JBN ABO / 03/2011 / Ajout de la devise et date de validité */
/*              : PHA    / 27/06/2012 / loc_date                             */
/*===========================================================================*/
  loc_idrib    NUMBER;
  loc_numgar   NUMBER;
  loc_codope   NUMBER;
  loc_date     DATE;
  loc_devise number;
BEGIN
  loc_numgar := a_numgar;
  loc_codope := a_codope;
  loc_date:=trunc(a_date);
  loc_devise:=a_devise;

  <<debut>>
  WHILE (loc_idrib IS NULL)
  LOOP
    BEGIN
      SELECT MAX (rib.idrib)
       INTO loc_idrib
       FROM rib
      WHERE rib.numindiv = a_numindiv
        AND rib.codope = loc_codope
        AND rib.numgar = loc_numgar
        AND rib.TYPE = a_dec_enc
        AND loc_date >= rib.debut
        and nvl(loc_devise,rib.devise_compte) = rib.devise_compte
        and ((rib.fin is null) or (loc_date	<= rib.fin))
        ;
    END;

    IF (loc_idrib IS NULL)
    THEN
      IF (NVL(loc_numgar,-1) != 0)
      THEN
        loc_numgar := 0;
        GOTO debut;
      ELSIF (NVL(loc_codope,-1) != 0)
      THEN
        loc_codope := 0;
        GOTO debut;
      ELSIF (loc_date != TO_DATE ('3000', 'yyyy'))
      THEN
        loc_date := TO_DATE ('3000', 'yyyy');
        GOTO debut;
      ELSE
        loc_idrib := 0;
      END IF;
    END IF;
  END LOOP;

  RETURN (loc_idrib);
END F_BENE_RIB;
