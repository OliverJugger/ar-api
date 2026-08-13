CREATE FORCE VIEW ARTHUS.V_BENE_JUSTIF AS
SELECT DISTINCT TO_NUMBER (repartition.nosin) nosin,
                   repartition_bene.numbene_dest numindiv, adhe_cntrt.numgar,
                   repartition_bene.numbene, repartition.idadhesion, 2 code,
                      'Du :'
                   || ' '
                   || TO_CHAR (SIN.datesurv, 'dd/mm/yy')
                   || ' '
                   || 'Type :'
                   || ' '
                   || libelle.libelle libelle_sin,
                   16 type_bene
              FROM adhe_cntrt, libelle, SIN, repartition, repartition_bene
             WHERE adhe_cntrt.idadhesion = repartition.idadhesion
               AND libelle.mnemo = 'RISQ'
               AND libelle.code = SIN.norisq
               AND repartition.nosin = SIN.nosin
               AND repartition_bene.idrepartition = repartition.idrepartition
               AND repartition_bene.valide = 'O'
               AND repartition.valide = 'O'
   UNION
   SELECT DISTINCT TO_NUMBER (SIN.nosin), SIN.numindiv_corres, 0,
                   SIN.numindiv_corres, 0, 2 code,
                      'Du :'
                   || ' '
                   || TO_CHAR (SIN.datesurv, 'dd/mm/yy')
                   || ' '
                   || 'Type :'
                   || ' '
                   || libelle.libelle libelle_sin,
                   15
              FROM libelle, SIN
             WHERE libelle.mnemo = 'RISQ'
               AND libelle.code = SIN.norisq
               AND SIN.numindiv_corres IS NOT NULL
   UNION
   SELECT proposition.idpropo, proposition.numindiv, contrat.numgar,
          proposition.numindiv, 0, 14 code,
          DECODE (proposition.objet, 1, produit.libelle, contrat.refcie), 14
     FROM proposition, contrat, produit
    WHERE produit.numprod = contrat.numprod
      AND proposition.idobjet =
                DECODE (proposition.objet,
                        1, produit.numprod,
                        contrat.numgar
                       )
   UNION
   SELECT adhe_cntrt.idadhesion, adhe_cntrt.numadhe, adhe_cntrt.numgar,
          adhe_cntrt_membre.numindiv, adhe_cntrt.idadhesion, 4 code,
          adhe_cntrt.ref_ext, 12
     FROM adhe_cntrt, adhe_cntrt_membre
    WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
   UNION
   SELECT contrat.numgar, contrat.numcli, contrat.numgar, contrat.numcli, 0,
          8 code, contrat.refcie, 3
     FROM contrat
   UNION
   SELECT adhe_cntrt.idadhesion, adhe_cntrt.numadhe, adhe_cntrt.numgar,
          adhe_cntrt.numadhe, adhe_cntrt.idadhesion, 4 code,
          adhe_cntrt.ref_ext, 4
     FROM adhe_cntrt
   UNION 
   SELECT  to_number(dossier_sante.num_dossier), dossier_sante.numassu, NULL,
          dossier_sante.numindiv, NULL, 20 code,
          NULL, 20
     FROM dossier_sante
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BENE_JUSTIF FOR ARTHUS.V_BENE_JUSTIF
