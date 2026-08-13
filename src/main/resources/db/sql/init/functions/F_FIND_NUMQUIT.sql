CREATE FUNCTION ARTHUS.F_FIND_NUMQUIT (
   i_numgar     IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
 , i_deb_base   IN   AFFIL_PORTE_QTTC.DEB_BASE%TYPE
 , o_code_ano   OUT  AFFIL_ANO.NUMANO%TYPE
)
   RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_FIND_NUMQUIT.sql                                         */
/* Domaine      : Cotisations                                                */
/* Version      : V1.0                                                       */
/* Auteur       : JBO                                                        */
/* Création     : 27/05/2016                                                 */
/* Description  : Recherche du numéro de quittance à partir des infos DSN    */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/
  loc_numquit    QTTC_GLOBAL.NUMQUIT%TYPE:=0;

BEGIN
    o_code_ano:=0;

  -- Recherche du numéro de quittance
  SELECT DISTINCT nvl(max(q.numquit),0)
    INTO loc_numquit
    FROM QTTC_GLOBAL q
   WHERE q.NUMGAR = i_numgar
     AND i_deb_base BETWEEN  q.debut AND q.fin
     AND q.comptant not in ('R')
     AND q.numquit NOT IN (SELECT f.NUMFACT FROM facture_annul f)
   ORDER BY q.numquit ASC;


   IF loc_numquit = 0 THEN
    -- Recheche si la quittance est régularisée
    SELECT DISTINCT nvl(max(q.numquit),0)
      INTO loc_numquit
      FROM QTTC_GLOBAL q
     WHERE q.NUMGAR = i_numgar
     AND i_deb_base BETWEEN  q.debut AND q.fin
       AND q.comptant in ('R')
       AND q.numquit NOT IN (SELECT f.NUMFACT FROM facture_annul f)
     ORDER BY q.numquit ASC;

     IF loc_numquit > 0 THEN
       o_code_ano:=88; -- Echéance régularisée, affectation impossible
     END IF;
   END IF;

   IF loc_numquit = 0 THEN
    -- Recheche si la quittance est annuléé
    SELECT DISTINCT nvl(max(q.numquit),0)
      INTO loc_numquit
      FROM QTTC_GLOBAL q
     WHERE q.NUMGAR = i_numgar
     AND i_deb_base BETWEEN  q.debut AND q.fin
       AND q.comptant in ('A')
       AND q.numquit NOT IN (SELECT f.NUMFACT FROM facture_annul f)
     ORDER BY q.numquit ASC;

     IF loc_numquit > 0 THEN
       o_code_ano:=89; -- Echéance annulée, affectation impossible
     END IF;
   END IF;

   IF loc_numquit = 0 THEN
     o_code_ano:=87; -- L’appel à blanc n’a pas été effectué
     loc_numquit:=NULL;
   END IF;


  RETURN (loc_numquit);


EXCEPTION
  WHEN OTHERS THEN
    o_code_ano:=1;
    RETURN NULL;
END F_FIND_NUMQUIT ;
