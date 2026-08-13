CREATE FORCE VIEW ARTHUS.V_SIN_SITU AS
Select	0		Etat,
	sysdate		D_regl,
	nosin		Nosin
From    sntr_prev
Where   nosin 	not in 	(
			Select 	nosin
			From 	v_histo_calcul
			Where	sntr_prev.nosin=v_histo_calcul.nosin
			)
union
Select	1		Etat,
	nvl(decaismt.datpay,sysdate)	D_regl,
	nosin		Nosin
From	v_histo_calcul,
	affectation,
	decaismt
Where	v_histo_calcul.numdec		=	affectation.numaffec
And     affectation.numdecaismt		=	decaismt.numdecaismt
And     decaismt.codope			=	2
And     decaismt.montant		>	0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SIN_SITU FOR ARTHUS.V_SIN_SITU
