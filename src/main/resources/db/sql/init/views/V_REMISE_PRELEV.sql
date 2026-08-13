CREATE FORCE VIEW ARTHUS.V_REMISE_PRELEV AS
select	vs_compte.numsoc,
		societe.refsoc,
		societe.nom					nom_soc,
		remise_prelev.numremise,
			remise_prelev.numremise||' du '||
			to_char(remise_prelev.datrem,'dd/mm/yyyy')||' - '||
			remise_prelev.nombre||' virements'	lib_remise,
		remise_prelev.datrem				datrem,
		to_char(remise_prelev.datrem,'dd/mm/yy')	edatrem,
		remise_prelev.numcpte				numcpte,
		vs_compte.numcpte||' - '||vs_compte.libcompte	lib_compte,
		remise_prelev.nombre,
		remise_prelev.valide,
		remise_prelev.datvalide				datvalide,
		to_char(remise_prelev.datvalide,'dd/mm/yy')	edatvalide,
		remise_prelev.datedit				datedit,
		to_char(remise_prelev.datedit,'dd/mm/yy')	edatedit,
		remise_prelev.datdisk				datdisk,
		to_char(remise_prelev.datdisk,'dd/mm/yy')	edatdisk,
		remise_prelev.numutil,
		utilisateur.nom,
		utilisateur.pseudo,
		remise_prelev.dataccuse,
		remise_prelev.datope,
		to_char(remise_prelev.dataccuse,'dd/mm/yy')	edataccuse,
		remise_prelev.numutil_accuse,
		utilisateur_accuse.nom				nom_accuse,
		utilisateur_accuse.pseudo			pseudo_accuse,
		remise_prelev.montant,
		remise_prelev.monnaie,
		remise_prelev.montant_d,
		remise_prelev.monnaie_d
        from	remise_prelev,
		vs_compte,
		util utilisateur,
		util utilisateur_accuse,
		societe
	where	vs_compte.numcpte  = remise_prelev.numcpte
	and	vs_compte.numsoc = societe.numsoc
	and	remise_prelev.numutil = utilisateur.numutil (+)
	and	remise_prelev.numutil_accuse = utilisateur_accuse.numutil (+)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_PRELEV FOR ARTHUS.V_REMISE_PRELEV
