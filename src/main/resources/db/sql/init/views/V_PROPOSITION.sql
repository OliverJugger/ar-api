CREATE FORCE VIEW ARTHUS.V_PROPOSITION AS
Select
	proposition.idpropo,
	proposition.refext,
	proposition.numindiv,
	Substr( Upper(indvs.nom) ||' '|| Initcap(indvs.prenom),1,32) nom,
	proposition.objet,
	ARTHUS.pk_libelle.f_lib('PROP_OBJET',proposition.objet) lib_objet,
	proposition.idobjet,
	f_objet_propo(proposition.idobjet,proposition.objet) lib_idobjet,
	proposition.cible,
	ARTHUS.pk_libelle.f_lib('PROP_CIBLE',proposition.cible) lib_cible,
	proposition.origine,
	ARTHUS.pk_libelle.f_lib('PROP_ORIGI',proposition.origine) lib_origine,
	proposition.score,
	ARTHUS.pk_libelle.f_lib('PROP_SCORE',proposition.score) lib_score,
	proposition.commercial,
	ARTHUS.pk_libelle.f_lib('PROP_COMME',proposition.commercial) lib_commercial,
	proposition.mt_estim,
	proposition.numutil,
	f_nomutil(proposition.numutil,3) nom_util,
	j2d(f_etat_propo(proposition.idpropo,sysdate,3)) debut,
	f_etat_propo(proposition.idpropo,sysdate,1) situation,
	ARTHUS.pk_libelle.f_lib('PROP_ETAT',
		f_etat_propo(proposition.idpropo,sysdate,1)) lib_situation,
	f_etat_propo(proposition.idpropo,sysdate,2) motif,
	ARTHUS.pk_libelle.f_lib('PROP_NATUR',
		f_etat_propo(proposition.idpropo,sysdate,2)) lib_motif,
	f_apporteur(14,proposition.idpropo,
			j2d(f_etat_propo(proposition.idpropo,sysdate,3)))
						numapporteur,
	decode(f_apporteur(14,proposition.idpropo,
		j2d(f_etat_propo(proposition.idpropo,sysdate,3))),0,'',
		Substr( Upper(indvs_apporteur.nom) ||' '||
				Initcap(indvs_apporteur.prenom),1,32)
		) lib_apporteur
	From indvs indvs_apporteur,indvs,proposition
	Where indvs.numindiv=proposition.numindiv
	And	indvs_apporteur.numindiv(+)=f_apporteur(14,proposition.idpropo,
		j2d(f_etat_propo(proposition.idpropo,sysdate,3)))
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PROPOSITION FOR ARTHUS.V_PROPOSITION
