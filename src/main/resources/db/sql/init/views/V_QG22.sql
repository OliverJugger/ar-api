CREATE FORCE VIEW ARTHUS.V_QG22 AS
select	grnts.numinterm						numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
        1                                                       tfc,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	indvs_assu.nom || ' '|| indvs_assu.prenom		nom_assu,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YY')			qttc_efin,
	qttc_global.numindiv					numassu,
	qttc_global.idadhesion,
	-sum(qttc_taxe.montant)					mt_ttc,
        qttc_taxe.numbene,
        indvs_bene.nom||' '||indvs_bene.prenom                  nombene,
        qttc_taxe.type_taxe                                     type_tfc,
        libelle.libelle                                         libtfc,
	qttc_global.mt_affec
from	qttc_global,
	qttc_taxe,
	grnts,
	indvs indvs_assu,
	indvs indvs_cli,
        indvs indvs_bene,
        libelle,
	orgns
where	qttc_global.type_qttc	!= 3
and	qttc_global.comptant	!= 'R'
and	qttc_taxe.montant	!= 0
and	qttc_taxe.numquit = qttc_global.numquit
and	grnts.numgar = qttc_global.numgar
and	indvs_assu.numindiv  	= qttc_global.numindiv
and	indvs_cli.numindiv  	= grnts.numcli +0
and	orgns.numorg		= grnts.numorg  +0
and	indvs_bene.numindiv     = qttc_taxe.numbene
and     libelle.mnemo           = 'TYPTAX'
and     libelle.code            = qttc_taxe.type_taxe
group by
	grnts.numinterm,
	grnts.numorg,
	orgns.nom,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom	,
	indvs_assu.nom || ' '|| indvs_assu.prenom,
	nvl(grnts.refcie_chapeau,'Pas de regroupement'),
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')	,
	to_char(qttc_global.fin  ,'DD/MM/YY')	,
	qttc_global.numindiv,
	qttc_global.idadhesion,
        qttc_taxe.numbene,
        indvs_bene.nom||' '||indvs_bene.prenom,
        qttc_taxe.type_taxe,
        libelle.libelle,
	qttc_global.mt_affec
union
select	grnts.numinterm						numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
        2                                                       tfc,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	indvs_assu.nom || ' '|| indvs_assu.prenom		nom_assu,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YY')			qttc_efin,
	qttc_global.numindiv					numassu,
	qttc_global.idadhesion,
	sum(qttc_frais.montant)					mt_ttc,
        qttc_frais.numbene,
        indvs_bene.nom||' '||indvs_bene.prenom                  nombene,
        qttc_frais.type_frais                                   type_tfc,
        libelle.libelle                                         libtfc,
	qttc_global.mt_affec
from	qttc_global,
	qttc_frais,
	grnts,
	indvs indvs_assu,
	indvs indvs_cli,
        indvs indvs_bene,
        libelle,
	orgns
Where	qttc_frais.numquit = qttc_global.numquit
And	qttc_global.type_qttc	= 2
and	qttc_global.comptant	!= 'R'
and	qttc_frais.montant	!= 0
and	grnts.numgar 		= qttc_global.numgar
and	indvs_assu.numindiv  	= qttc_global.numindiv
and	indvs_cli.numindiv  	= grnts.numcli +0
and	orgns.numorg		= grnts.numorg  +0
and	indvs_bene.numindiv     = decode(qttc_frais.numbene,
					0, grnts.numinterm,
					qttc_frais.numbene)
and     libelle.mnemo           = decode(qttc_frais.numfor,
					0, 'TYPFRAIS',
					'FRAIS_GAR')
and     libelle.code            = qttc_frais.type_frais
group by
	grnts.numinterm,
	grnts.numorg,
	orgns.nom,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom	,
	indvs_assu.nom || ' '|| indvs_assu.prenom,
	nvl(grnts.refcie_chapeau,'Pas de regroupement'),
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')	,
	to_char(qttc_global.fin  ,'DD/MM/YY')	,
	qttc_global.numindiv,
	qttc_global.idadhesion,
        qttc_frais.numbene,
        indvs_bene.nom||' '||indvs_bene.prenom,
        qttc_frais.type_frais,
        libelle.libelle,
	qttc_global.mt_affec
union
select	grnts.numinterm						numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
        4                                                       tfc,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	indvs_assu.nom || ' '|| indvs_assu.prenom		nom_assu,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YY')			qttc_efin,
	qttc_global.numindiv					numassu,
	qttc_global.idadhesion,
	-sum(qttc_comm.montant)				mt_ttc,
        qttc_comm.numbene,
        indvs_bene.nom||' '||indvs_bene.prenom                  nombene,
        qttc_comm.type_comm                                   type_tfc,
        libelle.libelle                                         libtfc,
	qttc_global.mt_affec
from	qttc_global,
	qttc_comm,
	grnts,
	indvs indvs_assu,
	indvs indvs_cli,
        indvs indvs_bene,
        libelle,
	orgns
Where	qttc_comm.numquit = qttc_global.numquit
And	qttc_global.type_qttc	= 2
and	qttc_global.comptant	!= 'R'
and	qttc_comm.montant	!= 0
and	grnts.numgar = qttc_global.numgar
and	indvs_assu.numindiv  	= qttc_global.numindiv
and	indvs_cli.numindiv  	= grnts.numcli
and	orgns.numorg		= grnts.numorg
and	indvs_bene.numindiv     = qttc_comm.numbene
and     libelle.mnemo           = 'TYPCOMM'
and     libelle.code            = qttc_comm.type_comm
group by
	grnts.numinterm,
	grnts.numorg,
	orgns.nom,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom	,
	indvs_assu.nom || ' '|| indvs_assu.prenom,
	nvl(grnts.refcie_chapeau,'Pas de regroupement'),
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')	,
	to_char(qttc_global.fin  ,'DD/MM/YY')	,
	qttc_global.numindiv,
	qttc_global.idadhesion,
        qttc_comm.numbene,
        indvs_bene.nom||' '||indvs_bene.prenom,
        qttc_comm.type_comm,
        libelle.libelle,
	qttc_global.mt_affec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QG22 FOR ARTHUS.V_QG22
