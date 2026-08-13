CREATE FORCE VIEW ARTHUS.V_LISTE_VARIABLE AS
select	nom_fonction nom
from	v_rep_fonction
union
select	nom_variable
from	def_variable
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LISTE_VARIABLE FOR ARTHUS.V_LISTE_VARIABLE
