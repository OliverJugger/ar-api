CREATE FORCE VIEW ARTHUS.V_GARCTRAVT AS
Select  distinct
        gar_cntrt.nomgar   	nomgar
,       gar_cntrt.libelle  	libelle
,       avnt_cntrt_gart.numfor 	numfor
,       gar_cntrt.type     	typgar
,       cntrt_trait.numgar      numgar
,       cntrt_trait.numav       numav
,       cntrt_trait.debut     	datedeb
,       cntrt_trait.fin 	datefin
,       cntrt_trait.valide      valide
From    gar_cntrt
,       cntrt_trait,
	avnt_cntrt_gart
Where 	gar_cntrt.numfor = avnt_cntrt_gart.numfor
and	avnt_cntrt_gart.numav = cntrt_trait.numav
and     avnt_cntrt_gart.numgar = cntrt_trait.numgar
and	gar_cntrt.numgar = cntrt_trait.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GARCTRAVT FOR ARTHUS.V_GARCTRAVT
