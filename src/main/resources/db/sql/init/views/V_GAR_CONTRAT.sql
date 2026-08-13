CREATE FORCE VIEW ARTHUS.V_GAR_CONTRAT AS
Select  Numgar,
 Numfor,
 Nomgar,
 Datapli,
 Datper,
 Libelle,
 Valide,
 obligatoire,
 1   Type
From gar_cntrt
Where numfor Not In (
 Select numfor
 from grp_gar_def,
  grp_gar
 Where grp_gar.numgrpgar = grp_gar_def.numgrpgar
 and grp_gar.etendue = 2
 and grp_gar.clef = gar_cntrt.numgar )
Union
Select grp_gar.clef  numgar,
 grp_gar.numgrpgar numfor,
 grp_gar.nomgrpgar nomgar,
 grp_gar.datapli,
 grp_gar.datper,
 grp_gar.libelle,
 grp_gar.valide,
 grp_gar.obligatoire,
 2   Type
From grp_gar
Where grp_gar.etendue = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_CONTRAT FOR ARTHUS.V_GAR_CONTRAT
