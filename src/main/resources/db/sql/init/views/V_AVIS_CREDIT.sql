CREATE FORCE VIEW ARTHUS.V_AVIS_CREDIT AS
select	numremise,
                numcpte,
                datrem,
                nombre,
                montant,
                valide,
		'Brd. Compte N°'||numcpte||' - '||nombre||' Prelevements.' lib_prelev,
		1 type_remise
        from	remise_prelev
        Union
        Select
                numremise,
                remise_globale.numcpte,
                daterem,
                nombre,
                montant,
                valide,
                ' Remise '||compte.libcompte||' le '||d2e(remise_globale.daterem) lib_remise,
		2 type_remise
        From compte,
	     remise_globale
        where compte.numcpte=remise_globale.numcpte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AVIS_CREDIT FOR ARTHUS.V_AVIS_CREDIT
