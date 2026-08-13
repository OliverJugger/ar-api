CREATE FORCE VIEW ARTHUS.V_LIB_ENCAISMT AS
select	encaismt.codope					codope,
	encaismt.numencaismt				numencaismt,
	'Encaissement de prime '||
		'N° '||
		encaismt.numencaismt||' du '||
		to_char(encaismt.datpay,'dd/mm/yyyy')	libelle,
	'en12'						codapli
from	encaismt
where	encaismt.codope = 4
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_ENCAISMT FOR ARTHUS.V_LIB_ENCAISMT
