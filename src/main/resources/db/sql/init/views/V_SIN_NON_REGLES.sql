CREATE FORCE VIEW ARTHUS.V_SIN_NON_REGLES AS
Select	nosin
From    sntr_prev
Where   nosin 	not in 	(
			Select 	nosin
			From 	v_histo_calcul
			Where	sntr_prev.nosin=v_histo_calcul.nosin
			)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SIN_NON_REGLES FOR ARTHUS.V_SIN_NON_REGLES
