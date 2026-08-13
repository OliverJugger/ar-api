CREATE FORCE VIEW ARTHUS.V_SIN_DELEG AS
select numdec, sinistre.codfrais, libelle,
decode (to_char(datsin,'YYYY'),
        to_char(sysdate,'YYYY'),to_char(datsin,'YYYY'),
        to_char(sysdate,'YYYY')-1,to_char(datsin,'YYYY'),
        'anterieurs' ) exercice,
        numgar,sum(mtfrais) mtprest, sum(mtreel) mremb
from sinistre, natfrais
where natfrais.codfrais = sinistre.codfrais
group by numdec, sinistre.codfrais, libelle,
decode (to_char(datsin,'YYYY'),
        to_char(sysdate,'YYYY'),to_char(datsin,'YYYY'),
        to_char(sysdate,'YYYY')-1,to_char(datsin,'YYYY'),
        'anterieurs' ), numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SIN_DELEG FOR ARTHUS.V_SIN_DELEG
