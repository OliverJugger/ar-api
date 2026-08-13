CREATE procedure ARTHUS.ins_rib (
				a_numindiv 	in 	Number,
				a_nom 		in 	Varchar2,
				a_prenom	in 	Varchar2,
				a_codc1 	in 	Number,
				a_creation in	Date default trunc(sysdate) )
As
-- Variable de reconnaissance SCCS
-- @(#)ins_rib.sql	1.2    02/08/13
loc_idrib	Number(9);
loc_intitule	Varchar2(30);
loc_qualite	Varchar2(10);
loc_numutil	Number;
BEGIN
loc_numutil := f_numutil;
Begin
	Select	libelle
	Into	loc_qualite
	From	libelle
	Where	mnemo = 'CODC1'
	and	code = a_codc1;
	Exception When No_data_found then loc_qualite := 'M';
End;
loc_intitule := Substr( loc_qualite ||' '|| a_nom ||' '|| a_prenom, 1, 30 );
Begin
Select 	idrib.nextval
Into	loc_idrib
From	Dual;
insert into rib(idrib,type,numindiv,numgar,codope,modpmt,intitule,debut,
	devise_compte,devise_ope,creation,numutil_creation,nature)
select 	loc_idrib,1,a_numindiv,0,0,prmt.dfmdpmt,
	loc_intitule, a_creation,pk_devise.devise_ref,pk_devise.devise_ref,sysdate,loc_numutil,1
from	prmt;
Select 	idrib.nextval
Into	loc_idrib
From	Dual;
insert into rib(idrib,type,numindiv,numgar,codope,modpmt,intitule,debut,
	devise_compte,devise_ope,creation,numutil_creation,nature)
select 	loc_idrib,2,a_numindiv,0,0,prmt.mdprvt,
	loc_intitule, a_creation,pk_devise.devise_ref,pk_devise.devise_ref,sysdate,loc_numutil,1
from	prmt;
End;
END;
/
