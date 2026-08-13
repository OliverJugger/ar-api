CREATE FORCE VIEW ARTHUS.V_ROLE_FROM_SINISTRE AS
select  1 typ_ref, 1 typ_gest, numfor ref, f_cpta_role(numfor,1,1) role from v_distinct_numfor_sinistre
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ROLE_FROM_SINISTRE FOR ARTHUS.V_ROLE_FROM_SINISTRE
