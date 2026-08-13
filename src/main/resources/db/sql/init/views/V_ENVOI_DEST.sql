CREATE FORCE VIEW ARTHUS.V_ENVOI_DEST AS
select distinct etendue, clef, numindiv_dest
	from envoi where clef is not null
    union
    select distinct etendue, clef, numindiv_dest
	from envoi_mail where clef is not null
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ENVOI_DEST FOR ARTHUS.V_ENVOI_DEST
