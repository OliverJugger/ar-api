CREATE FORCE VIEW ARTHUS.V_RETROCESSION AS
Select	qttc_global.type_qttc *2		etendue,
	decode( qttc_global.type_qttc,
			1, qttc_global.numgar,
			2, qttc_global.idadhesion)
						cle,
	qttc_global.debut			debut,
	qttc_global.fin 			fin,
	qttc_retro.prelev_revers		mode_retro,
	qttc_retro.type_comm,
	qttc_retro.numbene,
	ARTHUS.pk_cotis.totretro( qttc_global.numquit,
			qttc_retro.type_comm,
			qttc_retro.numbene,
			qttc_retro.numfor,
			1)
	-
	ARTHUS.pk_cotis.retro_regle(
			qttc_global.numquit,
			1,
			qttc_retro.type_comm,
			qttc_retro.numbene,
			qttc_retro.numfor )
	+
	ARTHUS.pk_cotis.retro_due(
			qttc_global.numquit,
			qttc_retro.type_comm,
			qttc_retro.numbene,
			qttc_retro.numfor )
						montant
From	qttc_global,
	qttc_retro
Where	qttc_global.numquit = qttc_retro.numquit
and	qttc_global.type_qttc != 3
and	qttc_global.comptant != 'R'
and Not Exists (
	Select	1
	From	emission
	where 	emission.codope = 4
	and	emission.numfact = qttc_global.numquit
	and	emission.numrelance = 99
	)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RETROCESSION FOR ARTHUS.V_RETROCESSION
