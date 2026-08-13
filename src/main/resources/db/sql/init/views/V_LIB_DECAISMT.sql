CREATE FORCE VIEW ARTHUS.V_LIB_DECAISMT AS
select	decaismt.codope					codope,
	decaismt.numdecaismt				numdecaismt,
	'Règlement '||
		decode(decaismt.codope,
			1,'maladie',
			2,'prévoyance')||
		'  N° '||
		decaismt.numdecaismt||' du '||
		to_char(decaismt.datpay,'dd/mm/yyyy')	libelle,
	''						codapli
from	decaismt
where	decaismt.codope in (1,2)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_DECAISMT FOR ARTHUS.V_LIB_DECAISMT
