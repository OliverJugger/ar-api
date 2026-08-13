CREATE FORCE VIEW ARTHUS.V_GS18 AS
Select	sinistre.numsin,
	sinistre.numgar,
	ARTHUS.pk_qttc.f_sel_numgar(sinistre.numgar) numgar_ref,
	sinistre.numfor,
	ARTHUS.pk_qttc.f_sel_numfor(sinistre.numgar, sinistre.numfor) numfor_ref,
        sinistre.numindiv,
        sinistre.numassu,
        sinistre.codfrais,
        sinistre.datsin,
        natfrais.rubrique,
        decode(frmls.flag_regime,'C',sinistre.nbacte,0)	 nbacte,
        decode(frmls.flag_regime,'C',sinistre.mtfrais,0) mtfrais,
        sinistre.mtremb,
	sinistre.mtreel,
	sinistre_sante.num_dossier,
	sinistre_sante.numligne,
	sinistre_sante.elt_corp,
	sinistre_sante.typ_elt
From	sinistre, frmls, natfrais, sntr_dossier, sinistre_sante
Where	ARTHUS.pk_qttc.f_sel_numfor(sinistre.numgar, sinistre.numfor)=frmls.numfor
AND     sinistre.codfrais=natfrais.codfrais
AND     sinistre.numsin=sntr_dossier.numsin_sntr(+)
and     sntr_dossier.num_dossier=+sinistre_sante.num_dossier(+)
and     sntr_dossier.numligne=+sinistre_sante.numligne(+)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GS18 FOR ARTHUS.V_GS18
