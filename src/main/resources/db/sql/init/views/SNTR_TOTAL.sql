CREATE FORCE VIEW ARTHUS.SNTR_TOTAL AS
select codfrais,numindiv,numgar,datsin,mtprest,mtremb,
       mtfrais,numassu,numbene,username,typbene
       from sntr
       union
       select codfrais,numindiv,numgar,datsin,mtprest,mtremb,
       mtfrais,numassu,numbene,username,typbene
       from travsn
GO
CREATE OR REPLACE PUBLIC SYNONYM SNTR_TOTAL FOR ARTHUS.SNTR_TOTAL
