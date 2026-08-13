CREATE FORCE VIEW ARTHUS.V_VILLE AS
select ville, idadresse, numindiv
from pers_adresse
where defaut = 'O'
and type != 3
union
select adr5, adr_internationale.idadresse, pers_adresse.numindiv
from adr_internationale, pers_adresse
where exists (
	select 1
	from pers_adresse
	where defaut = 'O'
	and type = 3
	and pers_adresse.idadresse = adr_internationale.idadresse
)
and pers_adresse.idadresse = adr_internationale.idadresse +0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VILLE FOR ARTHUS.V_VILLE
