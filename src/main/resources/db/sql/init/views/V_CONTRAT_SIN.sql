CREATE FORCE VIEW ARTHUS.V_CONTRAT_SIN AS
select 	distinct adhe_cntrt.numgar,
		sin.numindiv,
		sin.nosin,
		sin.norisq,
		a.libelle libnorisq,
		decode(sin.datefin,'',1,2) nositu,
		sin.datesurv,
		adhe_cntrt.idadhesion,
		adhe_cntrt.ref_ext,
		sin.motif,
		sin.datefin,
		sin.datedecla,
		b.libelle libcaus,
		sin.cause,
		decode(sin.motif,'','',c.libelle) libmotif
	from	libelle a,
		libelle b,
		libelle c,
		sin,
		adhe_cntrt
	where	a.mnemo='RISQ'
	and	a.code = sin.norisq
	and	b.mnemo='CAUS'
	and	b.code=sin.cause
	and	c.mnemo='MOTIF_SIN'
	and	c.code=nvl(sin.motif,-2)
	and	adhe_cntrt.idadhesion = f_idadhesion_prev(sin.nosin)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CONTRAT_SIN FOR ARTHUS.V_CONTRAT_SIN
