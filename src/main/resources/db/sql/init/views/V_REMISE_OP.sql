CREATE FORCE VIEW ARTHUS.V_REMISE_OP AS
select	vs_compte.numsoc,
		societe.refsoc,
		societe.nom					nom_soc,
		remise_op.numremise,
			remise_op.numremise||' du '||
			to_char(remise_op.datrem,'dd/mm/yyyy')||' - '||
			remise_op.nombre||' virements'	lib_remise,
		remise_op.datrem				datrem,
		to_char(remise_op.datrem,'dd/mm/yy')		edatrem,
		remise_op.numcpte				numcpte,
		vs_compte.numcpte||' - '||vs_compte.libcompte	lib_compte,
		remise_op.nombre,
		remise_op.valide,
		remise_op.datvalide				datvalide,
		to_char(remise_op.datvalide,'dd/mm/yy')	edatvalide,
		remise_op.datedit				datedit,
		to_char(remise_op.datedit,'dd/mm/yy')		edatedit,
		remise_op.datdisk				datdisk,
		to_char(remise_op.datdisk,'dd/mm/yy')		edatdisk,
		remise_op.numutil,
		util.nom,
		util.pseudo,
		remise_op.montant,
		remise_op.monnaie,
		remise_op.montant_d,
		remise_op.monnaie_d,
		remise_op.numdest				numdest,
		decode(remise_op.numdest,'','',
		       remise_op.numdest||' - '||ARTHUS.pk_personne.f_nom(remise_op.numdest,32))
								lib_dest,
		remise_op.natrem				natrem
        from	remise_op,
		vs_compte,
		util,
		societe
	where	vs_compte.numcpte  = remise_op.numcpte
	and	vs_compte.numsoc = societe.numsoc
	and	remise_op.numutil = util.numutil (+)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_OP FOR ARTHUS.V_REMISE_OP
