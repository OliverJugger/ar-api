CREATE FUNCTION ARTHUS.F_ETAT_SNTRT_BY_DATE (
   a_numsin   IN   HISTO_SNTR_PREV.NOSIN%TYPE,
   a_date     IN   HISTO_SNTR_PREV.DEBUT%TYPE
)
/*========================================================================*/
/* Vues         : F_ETAT_SNTRT_BY_DATE.sql                                */
/* Domaine      : function                                                */
/* Version      : V1.0                                                    */
/* Auteur       : JBO                                                     */
/* Création     : 18/13/2013                                              */
/* Description  : Retourne 1 si ferme a la date passer sinon 0            */
/*========================================================================*/
/* Correction   : trigramme / date / commentaire                          */
/*========================================================================*/
RETURN NUMBER

AS
  loc_etat   NUMBER:=0;
  loc_debut  DATE;

BEGIN
  SELECT etat,debut
    INTO loc_etat,loc_debut
    FROM histo_sntr_prev h
   WHERE h.nosin =a_numsin
     AND debut = (SELECT MAX(h1.debut)
                    FROM histo_sntr_prev h1
                   WHERE h.nosin =h1.nosin
                     AND TRUNC(a_date) > h1.debut);

    IF LOC_ETAT = 2 and loc_debut < nvl(F_SNTR_PREV_DEBUT(a_numsin),loc_debut) THEN
       loc_etat := 1;
    END IF;

    RETURN(loc_etat);

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;

END F_ETAT_SNTRT_BY_DATE;
