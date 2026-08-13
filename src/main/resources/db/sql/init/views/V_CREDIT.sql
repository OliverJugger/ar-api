CREATE FORCE VIEW ARTHUS.V_CREDIT AS
select	numremise,
                numencaismt,
 		1 type_remise
        from	remise_banque
        Union
        Select
                numremise,
                numencaismt,
		2 type_remise
        From prelevement
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CREDIT FOR ARTHUS.V_CREDIT
