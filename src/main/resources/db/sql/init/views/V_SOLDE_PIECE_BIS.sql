CREATE FORCE VIEW ARTHUS.V_SOLDE_PIECE_BIS AS
Select  compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt,
        nvl( sum(montant), 0 )			debit,
        f_contrepartie (compte_tiers.idmvt)	credit
From    compte_tiers
Where   (sens = -1 and montant >= 0)
and not exists (select 1 from compensation
where compensation.idcomp=compte_tiers.idmvt)
and ((sens * montant) + f_contrepartie (idmvt)) != 0
Group by
        compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt
Union
Select  compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt,
        nvl( sum(montant * -1), 0 )		debit,
        f_contrepartie (compte_tiers.idmvt)	credit
From    compte_tiers
Where   (sens = 1 and montant < 0)
and not exists (select 1 from compensation
where compensation.idcomp=compte_tiers.idmvt)
and ((sens * montant) + f_contrepartie (idmvt)) != 0
Group by
        compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt
Union
Select  compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt,
        (f_contrepartie (compte_tiers.idmvt) * -1 )	debit,
        nvl( sum(montant), 0 )			credit
From    compte_tiers
Where   (sens = 1 and montant >= 0)
and not exists (select 1 from compensation
where compensation.idcomp=compte_tiers.idmvt)
and ((sens * montant) + f_contrepartie (idmvt)) != 0
Group by
        compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt
Union
Select  compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt,
        (f_contrepartie (compte_tiers.idmvt) * -1 )	debit,
        nvl( sum(montant * -1), 0 )		credit
From    compte_tiers
Where   (sens = -1 and montant < 0)
and not exists (select 1 from compensation
where compensation.idcomp=compte_tiers.idmvt)
and ((sens * montant) + f_contrepartie (idmvt)) != 0
Group by
        compte_tiers.numcli,
        compte_tiers.codope,
        compte_tiers.cle,
        compte_tiers.idmvt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SOLDE_PIECE_BIS FOR ARTHUS.V_SOLDE_PIECE_BIS
