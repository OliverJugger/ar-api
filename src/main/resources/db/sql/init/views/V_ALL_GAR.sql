CREATE FORCE VIEW ARTHUS.V_ALL_GAR AS
SELECT contrat_ref.numgar numgar, contrat_ref.numorg numorg,
          gar_cntrt_ref.TYPE typgar, gar_cntrt_ref.numfor numfor,
          formule.numass numass, TO_NUMBER (formule.branche) classe,
          formule.code_cmcr categorie, formule.nat_risq natrisq,
          f_code_reass (gar_cntrt_ref.numgar, gar_cntrt_ref.numfor, SYSDATE) codreass
          , gar_cntrt_ref.nomgar, formule.flag_regime,formule.typgar baseopt
     FROM contrat_ref, gar_cntrt_ref, formule
    WHERE contrat_ref.numgar = gar_cntrt_ref.numgar
      AND DECODE(gar_cntrt_ref.numgar,gar_cntrt_ref.numgar,gar_cntrt_ref.numfor,gar_cntrt_ref.numfor_ref) = formule.numfor
   UNION
   SELECT contrat_ref.numgar numgar, contrat_ref.numorg ,
          gar_cntrt_ref.TYPE typgar, gar_cntrt_ref.numfor numfor,
          garanties.numass numass, garanties.classe_gar classe,
          garanties.code_cmcr categorie, garanties.nat_risq natrisq,
          f_code_reass (gar_cntrt_ref.numgar, gar_cntrt_ref.numfor, SYSDATE) codreass
          , gar_cntrt_ref.nomgar, '' flag_regime,garanties.typgar baseopt
     FROM contrat_ref, gar_cntrt_ref, garanties
    WHERE contrat_ref.numgar = gar_cntrt_ref.numgar
      AND DECODE(gar_cntrt_ref.numgar,gar_cntrt_ref.numgar,gar_cntrt_ref.numfor,gar_cntrt_ref.numfor_ref) = garanties.numfor
    UNION
SELECT contrat_ref.numgar numgar, contrat_ref.numorg numorg,
          gar_cntrt_ref.TYPE typgar, adhe_coll_gar.numfor numfor,
          formule.numass numass, TO_NUMBER (formule.branche) classe,
          formule.code_cmcr categorie, formule.nat_risq natrisq,
          f_code_reass (adhe_coll_gar.numgar, adhe_coll_gar.numfor, SYSDATE) codreass
          , gar_cntrt_ref.nomgar, formule.flag_regime,formule.typgar baseopt
     FROM contrat_ref, adhe_coll_gar, gar_cntrt_ref, formule
    WHERE contrat_ref.numgar = adhe_coll_gar.numgar_ref
      AND adhe_coll_gar.numfor_ref = gar_cntrt_ref.numfor
      AND DECODE(adhe_coll_gar.numgar,adhe_coll_gar.numgar_ref,adhe_coll_gar.numfor,adhe_coll_gar.numfor_ref) = formule.numfor
   UNION
   SELECT contrat_ref.numgar numgar, contrat_ref.numorg ,
          gar_cntrt_ref.TYPE typgar, adhe_coll_gar.numfor numfor,
          garanties.numass numass, garanties.classe_gar classe,
          garanties.code_cmcr categorie, garanties.nat_risq natrisq,
          f_code_reass (adhe_coll_gar.numgar, adhe_coll_gar.numfor, SYSDATE) codreass
          , gar_cntrt_ref.nomgar, '' flag_regime,garanties.typgar baseopt
     FROM contrat_ref, adhe_coll_gar, gar_cntrt_ref, garanties
    WHERE contrat_ref.numgar = adhe_coll_gar.numgar_ref
      AND adhe_coll_gar.numfor_ref = gar_cntrt_ref.numfor
      AND DECODE(adhe_coll_gar.numgar,adhe_coll_gar.numgar_ref,adhe_coll_gar.numfor,adhe_coll_gar.numfor_ref) = garanties.numfor
          WITH CHECK OPTION
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ALL_GAR FOR ARTHUS.V_ALL_GAR
