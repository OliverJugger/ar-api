CREATE FORCE VIEW ARTHUS.T AS
select	lpad('-',level*6,' ')||nom 	arbre,
		codapli,
		type,
		fonction,
		sec,
		cle1,
		cle2
	from	appli
	connect	by prior codapli	= fonction
	start	with fonction		= 'DEBU'
GO
CREATE OR REPLACE PUBLIC SYNONYM T FOR ARTHUS.T
