CREATE FORCE VIEW ARTHUS.V_HISTO_TRANSFERT AS
Select	v_histo_trav_transfert.new_numgar    numgar,
	grnts.refcie
From	v_histo_trav_transfert,grnts
Where   v_histo_trav_transfert.new_numgar=grnts.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_TRANSFERT FOR ARTHUS.V_HISTO_TRANSFERT
