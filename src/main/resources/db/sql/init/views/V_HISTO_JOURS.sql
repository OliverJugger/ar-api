CREATE FORCE VIEW ARTHUS.V_HISTO_JOURS AS
SELECT   histo_calcul.idcalcul, histo_jours.idhisto,
            histo_calcul.idrepartition, histo_calcul.numbene,
            histo_jours.debut, histo_jours.fin,histo_jours.fin-histo_jours.debut+1 NBJOURS, histo_calcul.creation,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, 0)), 2) mtreval,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, -3)), 2) mtdedu,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, -1)), 2) mtprest,
			histo_jours.montant,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, -4)),
                   2) mt_nondedu,
            ROUND (SUM (f_total_histo_d (histo_jours.idhisto, 0)),
                   2
                  ) mtreval_d,
            ROUND (SUM (f_total_histo_d (histo_jours.idhisto, -3)),
                   2) mtdedu_d,
            ROUND (SUM (f_total_histo_d (histo_jours.idhisto, -1)),
                   2
                  ) mtprest_d,
		    histo_jours.montant_d,
            ROUND (SUM (f_total_histo_d (histo_jours.idhisto, -4)),
                   2
                  ) mt_nondedu_d,
            histo_calcul.numdec
       FROM histo_calcul, histo_jours
      WHERE histo_calcul.idcalcul = histo_jours.idcalcul
   GROUP BY histo_calcul.idcalcul,
            histo_jours.idhisto,
            histo_calcul.idrepartition,
            histo_calcul.numbene,
            histo_jours.debut,
            histo_jours.fin,
            histo_calcul.creation,
            histo_calcul.numdec,
			histo_jours.montant_d,
			histo_jours.montant
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_JOURS FOR ARTHUS.V_HISTO_JOURS
