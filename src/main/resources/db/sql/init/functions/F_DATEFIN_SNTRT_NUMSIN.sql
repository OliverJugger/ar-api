CREATE FUNCTION ARTHUS.F_DATEFIN_SNTRT_NUMSIN (a_numsin   IN   HISTO_SNTR_PREV.NOSIN%TYPE)
/*=========================================================================*/
/* FONCTION     : F_DATEFIN_SNTRT_NUMSIN.sql                               */
/* Domaine      : Prévoyance                                               */
/* Version      : V1.0                                                     */
/* Auteur       : JBO                                                      */
/* Création     : 18/13/2013                                               */
/* Description  : Retourne la date de fin du sinistre prévoyance sinon NULL*/
/*=========================================================================*/
/* Correction   : trigramme / date / commentaire                           */
/*=========================================================================*/
RETURN DATE
AS
  loc_datefin   DATE:=NULL;

BEGIN
  SELECT DECODE(etat,2,h.debut,NULL)
    INTO loc_datefin
    FROM histo_sntr_prev h
   WHERE h.nosin =a_numsin
     AND h.debut = (SELECT MAX(h1.debut)
                      FROM histo_sntr_prev h1
                     WHERE h.nosin =h1.nosin
                      AND TRUNC(SYSDATE) >= h1.debut);

    RETURN(loc_datefin);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(loc_datefin);
  WHEN OTHERS THEN
    RETURN(loc_datefin);

END F_DATEFIN_SNTRT_NUMSIN;
