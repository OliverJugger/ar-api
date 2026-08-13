CREATE FORCE VIEW ARTHUS.V_AFFECTATION AS
select 	compte_client.idaffec,
 	compte_client.codope,
	compte_client.numcli,
	compte_client.numfact,
	compte_client.numencaismt,
	compte_client.montant,
	compte_client.monnaie,
	compte_client.datope,
	'Le '||to_char(compte_client.datope,'DD/MM/YYYY')||' par '||
	modpmt.libelle||decode(encaismt.refpmt,'','',' n° '||
	lpad(to_char(encaismt.refpmt),7,'0')) libelle,
	'en12' codapli,
	encaismt.refpmt refpmt
from 	compte_client,
	encaismt,
	libelle modpmt
where 	encaismt.numencaismt	=	compte_client.numencaismt
and	modpmt.code		=	encaismt.modpmt
and	modpmt.mnemo		=	'MREGL'
and not exists 	(select 1
		 from 	idaffec_regul
		 where	compte_client.idaffec = idaffec_regul.idaffec
		 or 	compte_client.idaffec = idaffec_regul.idaffec_regul)
and	compte_client.montant>0
union
select 	compte_client.idaffec,
 	compte_client.codope,
	compte_client.numcli,
	compte_client.numfact,
	compte_client.numencaismt,
	compte_client.montant,
	compte_client.monnaie,
	compte_client.datope,
	'Le '||to_char(compte_client.datope,'DD/MM/YYYY')||' Annulation '
	libelle,
	'en12' codapli,
	encaismt.refpmt refpmt
from 	compte_client,
	encaismt,
	libelle modpmt
where 	encaismt.numencaismt	=	compte_client.numencaismt
and	modpmt.code		=	encaismt.modpmt
and	modpmt.mnemo		=	'MREGL'
and not exists 	(select 1
		 from 	idaffec_regul
		 where	compte_client.idaffec = idaffec_regul.idaffec
		 or 	compte_client.idaffec = idaffec_regul.idaffec_regul)
and	compte_client.montant<0
and	exists(select 1 from annul_encais where
		annul_encais.numencaismt=encaismt.numencaismt)
union
select 	compte_client.idaffec,
 	compte_client.codope,
	compte_client.numcli,
	compte_client.numfact,
	compte_client.numencaismt,
	compte_client.montant,
	compte_client.monnaie,
	compte_client.datope,
	'Le '||to_char(compte_client.datope,'DD/MM/YYYY')||
	' par désaffectation de la pièce N° '||
	compte_client.numfact libelle,
	'en12' codapli,
	encaismt.refpmt refpmt
from 	compte_client,
	encaismt,
	libelle modpmt
where 	encaismt.numencaismt	=	compte_client.numencaismt
and	modpmt.code		=	encaismt.modpmt
and	modpmt.mnemo		=	'MREGL'
and not exists 	(select 1
		 from 	idaffec_regul
		 where	compte_client.idaffec = idaffec_regul.idaffec
		 or 	compte_client.idaffec = idaffec_regul.idaffec_regul)
and	compte_client.montant<0
and	not exists(select 1 from annul_encais where
		annul_encais.numencaismt=encaismt.numencaismt)
union
select 	compte_client.idaffec,
 	compte_client.codope,
	compte_client.numcli,
	compte_client.numfact,
	facture_regul.numfact,
	compte_client.montant,
	compte_client.monnaie,
	compte_client.datope,
	'Reporté le '||
		to_char(facture_regul.datope,'DD/MM/YYYY')||
		' sur la pièce n° '||facture_regul.numfact,
	decode(compte_client.codope, 4, 'qg03', ''),
	facture_regul.numfact refpmt
from 	compte_client,
	facture_regul
where	compte_client.codope = facture_regul.codope
and	compte_client.numfact = facture_regul.numfact_regul
and exists 	(select 1
		 from 	idaffec_regul
		 where	compte_client.idaffec = idaffec_regul.idaffec_regul)
union
select 	compte_client.idaffec,
 	compte_client.codope,
	compte_client.numcli,
	compte_client.numfact,
	facture_regul.numfact_regul,
	compte_client.montant,
	compte_client.monnaie,
	compte_client.datope,
	'Par régularisation le '||
		to_char(facture_regul.datope,'DD/MM/YYYY')||
		' de la pièce n° '||facture_regul.numfact_regul,
	decode(compte_client.codope, 4, 'qg03', ''),
	facture_regul.numfact_regul refpmt
from 	compte_client,
	facture_regul
where	compte_client.codope = facture_regul.codope
and	compte_client.numfact = facture_regul.numfact
and exists 	(select 1
		 from 	idaffec_regul
		 where	compte_client.idaffec = idaffec_regul.idaffec)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFECTATION FOR ARTHUS.V_AFFECTATION
