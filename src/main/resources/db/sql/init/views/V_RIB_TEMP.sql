CREATE FORCE VIEW ARTHUS.V_RIB_TEMP AS
select IDRIB,TYPE,NUMINDIV,NUMGAR,CODBQUE,GUICHET,compte, clerib, bban, clef_iban
from rib
where
CODBQUE is not null and
GUICHET is not null and
compte is not null and
clerib is not null and
bban is not null and
clef_iban is not null
and length(bban) = 23
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RIB_TEMP FOR ARTHUS.V_RIB_TEMP
