CREATE FUNCTION ARTHUS."F_MONTANT_DU_D" (
   a_numfact   IN   NUMBER,
   a_codope     IN   NUMBER,   
   a_rappel     IN   NUMBER
)
   RETURN NUMBER
AS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/FUNCTIONS/F_MONTANT_DU_D.sql $:  Chemin

   loc_montant   NUMBER := 0;
   loc_montant_d NUMBER := 0;
   loc_numgar    qttc_global.numgar%TYPE;
   loc_mregl     facture.mregl%TYPE;
BEGIN
  -- dÃ©termine si une facture a un montant restant du et si par consÃ©quent 
  --  elle est concernÃ©e par une relance de cotisations, les cas de gestion sont les suivants :
  --	Facture annulÃ©e => renvoie 0
  --	Facture rÃ©gularisÃ©e par une autre renvoie 0
  --	Facture partiellement affectÃ©e => renvoie le solde
  --	Facture non Ã©mise => renvoie le solde
  --	Facture engagÃ©e dans le processus de relance => renvoie le solde du uniquement si le solde est supÃ©rieur au seuil sinon renvoie 0


   SELECT NVL(SUM (facture.montant)
          - SUM (NVL (f_totaffec (facture.numfact, facture.codope), 0)),0),
          NVL(SUM (facture.montant_d)
          - SUM (NVL (f_totaffec_d (facture.numfact, facture.codope), 0)),0)
          ,qttc_global.numgar
          ,facture.mregl
     INTO loc_montant ,loc_montant_d, loc_numgar, loc_mregl
     FROM facture, qttc_global
    WHERE facture.numfact = a_numfact
      AND facture.numfact = qttc_global.numquit
      AND facture.codope = a_codope
                         AND qttc_global.type_qttc != 3
      AND NOT EXISTS (
             SELECT 1
               FROM facture_regul
              WHERE facture_regul.codope = facture.codope
                AND facture_regul.numfact_regul = facture.numfact)
      AND NOT EXISTS (SELECT 1
               FROM facture_annul
              WHERE facture_annul.codope = facture.codope
                AND facture_annul.numfact = facture.numfact)
      GROUP BY qttc_global.numgar,facture.mregl;

   IF loc_montant_d =0 THEN 
     RETURN 0;
   ELSIF loc_montant > to_number(pk_relance.f_sel_param_relance (
                         I_etendue => 2,
                         I_cle     => loc_numgar,
                         I_codope  => 3,
                         I_niveau  => a_rappel,
                         I_type    => 1,
                         I_numgar  => loc_numgar,
                         I_modpmt  => loc_mregl))   THEN
    RETURN (loc_montant_d);
   ELSE RETURN 0;
   END IF;
EXCEPTION
  WHEN OTHERS THEN RETURN 0;
END;
