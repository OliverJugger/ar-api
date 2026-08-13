CREATE FORCE VIEW ARTHUS.V_TIERS_BALANCE AS
Select  compte_tiers.numcli							numindiv,
        ARTHUS.pk_personne.f_nom(compte_tiers.numcli, 32)  tiers,
        compte_tiers.idmvt,
        compte_tiers.sens,
		nvl( decode(compte_tiers.sens, -1, (compte_tiers.sens * compte_tiers.montant), 1, (f_contrepartie(compte_tiers.idmvt)) ), 0 )   debit,
        nvl( decode(compte_tiers.sens, -1, (f_contrepartie(compte_tiers.idmvt)), 1, (compte_tiers.sens * compte_tiers.montant) ), 0 )   credit,
		compte_tiers.monnaie,
        nvl( decode(compte_tiers.sens, -1, (compte_tiers.sens * compte_tiers.montant_d), 1, (f_contrepartie_d(compte_tiers.idmvt)) ), 0 )   debit_d,
        nvl( decode(compte_tiers.sens, -1, (f_contrepartie_d(compte_tiers.idmvt)), 1, (compte_tiers.sens * compte_tiers.montant_d) ), 0 )   credit_d,
		compte_tiers.monnaie_d
From    compte_tiers
where	not exists (select 1 from compensation
					where compensation.idcomp=compte_tiers.idmvt)
						and ((sens * montant) + f_contrepartie (idmvt)) != 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TIERS_BALANCE FOR ARTHUS.V_TIERS_BALANCE
