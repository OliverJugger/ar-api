CREATE FUNCTION ARTHUS."F_CT_RESP" (a_clef IN NUMBER, a_type IN NUMBER DEFAULT 1)
   RETURN VARCHAR2
IS
/*===========================================================================*/
/* Package      : F_CT_RESP.sql                                              */
/* Domaine      : Conrtat                                                    */
/* Version      : V1.0                                                       */
/* Auteur       : ???                                                        */
/* Création     : 01/01/1990                                                 */
/* Description  : fonction retournant la valeur du contrat responsable       */
/*===========================================================================*/
/* Evolution    : contrat responsable décompte unique                        */
/* Auteur       : ABO                                                        */
/* Date         : 23/07/2015                                                 */
/* Commentaire  : valeur de ct_resp pour un numgar donné                     */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/

   loc_retour   NUMBER;

--
   CURSOR c_gar(p_clef in NUMBER)
   IS
      SELECT formule.ct_resp
        FROM gar_cntrt, formule
       WHERE gar_cntrt.numfor = p_clef
         AND (gar_cntrt.numfor = formule.numfor);

   r_gar        c_gar%ROWTYPE;

   CURSOR c_cntrt(p_clef in NUMBER)
   IS
      SELECT contrat.ct_resp
        FROM gar_cntrt, contrat
       WHERE gar_cntrt.numfor = p_clef
         AND (gar_cntrt.numgar = contrat.numgar);
   r_cntrt      c_cntrt%ROWTYPE;

   CURSOR c_contrat(p_clef in NUMBER)
   IS
      SELECT contrat.ct_resp
        FROM contrat
       WHERE  contrat.numgar=p_clef;
   r_contrat      c_contrat%ROWTYPE;

BEGIN
  BEGIN
    IF a_type = 1 THEN
      OPEN c_gar(a_clef);
      FETCH c_gar INTO r_gar;
      loc_retour := r_gar.ct_resp;
      CLOSE c_gar;

    ELSIF a_type = 2 THEN
      OPEN c_contrat(a_clef);
      FETCH c_contrat INTO r_contrat;
      loc_retour := r_contrat.ct_resp;
      CLOSE c_contrat;
    ELSE
      OPEN c_cntrt(a_clef);
      FETCH c_cntrt INTO r_cntrt;
      loc_retour := r_cntrt.ct_resp;
      CLOSE c_cntrt;
    END IF;
  -- EXCEPTION
  -- WHEN OTHERS THEN LOC_RETOUR := 0;
  END;

  RETURN (loc_retour);
END F_CT_RESP;
