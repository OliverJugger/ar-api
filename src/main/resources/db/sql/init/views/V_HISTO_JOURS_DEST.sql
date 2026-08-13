CREATE FORCE VIEW ARTHUS.V_HISTO_JOURS_DEST AS
SELECT   histo_calcul.idcalcul, histo_jours.idhisto,
            histo_calcul.idrepartition, histo_calcul.numbene,
            histo_jours.debut, histo_jours.fin, histo_calcul.creation,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, 0)), 2) mtreval,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, -3)), 2) mtdedu,
            ROUND (SUM (f_total_histo (histo_jours.idhisto, -1)), 2) mtprest,
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
            ROUND (SUM (f_total_histo_d (histo_jours.idhisto, -4)),
                   2
                  ) mt_nondedu_d,
            histo_calcul.numdec,
            histo_calcul.NUMBENE_DEST,
            NVL(correspondant.numcorres,-1) NUMCORRES,
            NVL(CASE WHEN ARTHUS.pk_libelle.F_LIB_SENS_BY_MNEMO('RGLTDEST', 8) = correspondant.NAT_CORRES THEN 'SAISI' ELSE 'AUTRE' END, 'AUTRE') type_dest,
            repartition.nosin,
            repartition.numfor
       FROM histo_calcul
            INNER JOIN histo_jours ON  histo_calcul.idcalcul = histo_jours.idcalcul
            INNER JOIN repartition ON repartition.idrepartition = histo_calcul.idrepartition
            LEFT OUTER JOIN correspondant ON correspondant.contexte = 15
                                         AND correspondant.entite = REPARTITION.NOSIN
                                         AND correspondant.numcorres = histo_calcul.NUMBENE_DEST
                                         AND ARTHUS.PK_PREV.SEL_CORRES_BY_TYPE_DEST(REPARTITION.NOSIN , 15, correspondant.nat_corres, correspondant.numcorres) =+ histo_calcul.NUMBENE_DEST
   GROUP BY histo_calcul.idcalcul,
            histo_jours.idhisto,
            histo_calcul.idrepartition,
            histo_calcul.numbene,
            histo_jours.debut,
            histo_jours.fin,
            histo_calcul.creation,
            histo_calcul.numdec,
            histo_calcul.NUMBENE_DEST,
            NVL(correspondant.numcorres,-1),
            NVL(CASE WHEN ARTHUS.pk_libelle.F_LIB_SENS_BY_MNEMO('RGLTDEST', 8) = correspondant.NAT_CORRES THEN 'SAISI' ELSE 'AUTRE' END, 'AUTRE'),
            repartition.nosin,
            repartition.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_JOURS_DEST FOR ARTHUS.V_HISTO_JOURS_DEST
