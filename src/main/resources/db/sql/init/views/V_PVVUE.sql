CREATE FORCE VIEW ARTHUS.V_PVVUE AS
select sin.userid,
        sin.nosin,
        sin.cle_nosin,
        to_char(sin.datesurv,'dd/mm/yy') datesurv,
        to_char(sin.datedecla,'dd/mm/yy') datedecla,
        to_char(sin.datefin,'dd/mm/yy') datefin,
        to_char(sin.dateclot,'dd/mm/yy') dateclot,
        sin.anterieur,
        sin.numindiv,
        individu.matorg,
        individu.cless,
        individu.nom,
        individu.prenom,
        individu.qualite,
        individu.nomjf,
        sin.nositu,
        sin.norisq,
        sin.cause,
	sin.numclot,
        lble1.libelle libsitu ,
        lble2.libelle libgar ,
        lble3.libelle libcause
 from sin,individu,lble lble1,lble lble2,lble lble3
 where sin.numindiv   = individu.numindiv
   and lble1.mnemo(+) = 'SITU-SIN'
   and lble1.code (+) = sin.nositu
   and lble2.mnemo(+) = 'RISQ'
   and lble2.code (+) = sin.norisq
   and lble3.mnemo(+) = 'CAUS'
   and lble3.code (+) = sin.cause
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PVVUE FOR ARTHUS.V_PVVUE
