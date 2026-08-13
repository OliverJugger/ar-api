CREATE FORCE VIEW ARTHUS.V_DELEG_ARRET AS
SELECT   deleg_arret.idarret, deleg_arret.nosin, deleg_arret.idrepartition,
            deleg_arret.numbene, deleg_arret.debut, deleg_arret.fin,
            SUM (mt_brut_p) AS MT_BRUT_P, SUM (mt_reval_p) AS MT_REVAL_P, SUM (mt_dedu_p) AS MT_DEDU_P,
            SUM (mt_total_p) AS MT_TOTAL_P, deleg_arret.creation, deleg_arret.createur, deleg_arret.type, deleg_arret.nbjour
       FROM deleg_remb_cie, deleg_arret
      WHERE deleg_remb_cie.idarret = deleg_arret.idarret
   GROUP BY deleg_arret.idarret,
            deleg_arret.debut,
            deleg_arret.fin,
            deleg_arret.nosin,
            deleg_arret.idrepartition,
            deleg_arret.numbene,
            deleg_arret.creation,
            deleg_arret.createur,
            deleg_arret.type,
            deleg_arret.nbjour
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DELEG_ARRET FOR ARTHUS.V_DELEG_ARRET
