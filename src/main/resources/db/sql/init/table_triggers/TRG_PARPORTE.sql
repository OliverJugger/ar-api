CREATE TRIGGER ARTHUS.TRG_PARPORTE BEFORE INSERT OR UPDATE OF OUVERTE ON PARPORTE
FOR EACH ROW
   WHEN ( nvl(new.ouverte, 0) != nvl(old.ouverte, 0) ) declare
CURSOR fetch_adhesion is
	Select	adhesion.idadhesion,
		adhesion.numgar,
		adhesion.numindiv,
		min(adhesion.datapli)	datapli
	From	indvs,
		adhesion,
		contrat,
		porte_contrat
	Where	porte_contrat.numporte = :new.numporte
	and	contrat.numgar = porte_contrat.numgar
	and	contrat.numinterm = :new.numsoc
	and	contrat.numorg = :new.numorg
	and	adhesion.numgar = porte_contrat.numgar
	and 	adhesion.etat in	(
			select code from lble
			where mnemo='ETIN'
			and sens=0
		    	)
	and 	nvl(datper, sysdate) >= sysdate
	and	datapli != nvl(datper, datapli+1)
	and	adhesion.rang = 1
	and	indvs.numindiv = adhesion.numindiv
	and	indvs.regime = :new.numreg
	and	indvs.caisse = :new.numcaisse
	group by
		adhesion.idadhesion,
		adhesion.numgar,
		adhesion.numindiv
	;
	loc_adhesion	fetch_adhesion%ROWTYPE;
	loc_type_porte	number;
	loc_transmis	number;
	loc_last_idporte	number;
BEGIN
loc_type_porte := f_type_porte(:new.numporte);
IF (loc_type_porte = 1) THEN	/* On ne traite que Noemie */
/*	Insertion dans porte_tiers */
If (:new.ouverte = 3) then
	:new.ouverte := 1;	/* Re-ouverture */
End if;
If (:new.ouverte = 1) then
	if ( nvl(:new.numcaisse, 0) != 0 ) then
	ins_porte_tiers(:new.numporte, :new.numcaisse);	/* -> pk_porte.sql */
	end if;
End if;
/*	Insertion dans porte_adhesion / noemie */
/* On fetch les assures concernes par la caisse */
for loc_adhesion in fetch_adhesion
loop
/* On regarde s'il ya deja eu une demande	*/
loc_last_idporte := f_last_idporte(
			:new.numporte,
			loc_adhesion.numindiv,
			loc_adhesion.idadhesion);
loc_transmis := f_transmis(loc_last_idporte); /* Transmise ou non */
If (:new.ouverte = 1) then 	/* Il s'agit d'une ouverture */
	if (loc_last_idporte = -1) then		/* Jamais traite */
					/* On genere la demande */
		ins_noemie(
			:new.numporte, loc_adhesion.numindiv,
			loc_adhesion.idadhesion, loc_adhesion.numgar,
			loc_adhesion.datapli, '',
			'C', 6
			);
	end if;
Elsif (:new.ouverte = 2) then	/* Il s'agit d'une fermeture */
	if (loc_last_idporte != -1) then	/* Deja traite */
		if (loc_transmis = 1) then	/* Deja transmis */
					/* On genere une annulation */
			ins_porte_annul(
				:new.numporte,
				loc_adhesion.idadhesion,
				loc_adhesion.numindiv,
				14);
		elsif (loc_transmis = 2 or loc_transmis = 6) then
			begin	/* Pas encore transmis on delete */
			Delete	porte_adhesion
			Where	idporte = loc_last_idporte;
			end;
		end if;
	end if;
End if;
End loop;
END IF;
END;