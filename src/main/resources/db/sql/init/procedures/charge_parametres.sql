CREATE procedure ARTHUS.charge_parametres ( I_numero IN number,
						I_contexte IN number,
						I_cle2 IN number,
						I_numenvoi IN number,
						I_idtexte IN number,
						I_numutil IN Number,
						O_donnee OUT pk_texte.donnee)
is
CURSOR C_parametres is
select numfact,
       datemis
From	emission
Where	numfact=I_numero;
rec_C_parametres C_parametres%rowtype;
CURSOR C_parametres1 is
select numfact,
       datemis
From	emission
Where	numfact=I_numero
And	numrelance=0;
rec_C_parametres1 C_parametres1%rowtype;
CURSOR C_parametres2 is
select numfact,
       datemis
From	emission
Where	numfact=I_numero
And	numrelance=1;
rec_C_parametres2 C_parametres2%rowtype;
CURSOR C_parametres3 is
select numfact,
       datemis
From	emission
Where	numfact=I_numero
And	numrelance=2;
rec_C_parametres3 C_parametres3%rowtype;
CURSOR C_parametres4 is
select numfact,
       datemis
From	emission
Where	numfact=I_numero
And	numrelance=3;
rec_C_parametres4 C_parametres4%rowtype;
CURSOR C_parametres5 is
select numenvoi,
       datemis
From	envoi
Where	numenvoi=I_numenvoi;
rec_C_parametres5 C_parametres5%rowtype;
CURSOR C_parametres6 is
select numenvoi,
       datemis
From	envoi
Where	numero=I_numero
And	numindiv_dest=I_cle2
And	exists(select 1 from param_texte
			where numrelance=0
			and param_texte.idtexte=envoi.idtexte
		      );
rec_C_parametres6 C_parametres6%rowtype;
CURSOR C_parametres7 is
select numenvoi,
       datemis
From	envoi
Where	numero=I_numero
And	numindiv_dest=I_cle2
And	exists(select 1 from param_texte
		Where numrelance=0
		and param_texte.idtexte=envoi.idtexte
		      );
rec_C_parametres7 C_parametres7%rowtype;
CURSOR C_parametres8 is
select numenvoi,
       datemis
From	envoi
Where	numero=I_numero
And	numindiv_dest=I_cle2
And	exists(select 1 from param_texte
			where numrelance=2
			and param_texte.idtexte=envoi.idtexte
		       );
rec_C_parametres8 C_parametres8%rowtype;
CURSOR C_parametres9 is
select numenvoi,
       datemis
From	envoi
Where	numero=I_numero
And	numindiv_dest=I_cle2
And	exists(select 1 from param_texte
			where numrelance=3
			and param_texte.idtexte=envoi.idtexte
		       );
rec_C_parametres9 C_parametres9%rowtype;
CURSOR C_parametres10 is
Select 	sysdate,
	initiales,
	pseudo,
	tel,
	util.cellule
From 	util
Where	util.numutil = I_numutil;
rec_C_parametres10 C_parametres10%rowtype;
Begin
If (I_contexte=18)
	Then
	Begin
        Open C_parametres;
	Fetch C_parametres Into rec_C_parametres;
	Close C_parametres;
        O_donnee(3):=rec_C_parametres.numfact;
	O_donnee(4):=to_char(rec_C_parametres.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(3):=0;
	O_donnee(4):='';
	When  too_many_rows then
	O_donnee(3):=0;
        O_donnee(4):='';
	End;
	Begin
        Open C_parametres1;
	Fetch C_parametres1 Into rec_C_parametres1;
	Close C_parametres1;
        O_donnee(5):=rec_C_parametres1.numfact;
	O_donnee(6):=to_char(rec_C_parametres1.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(5):=0;
	O_donnee(6):='';
	When  too_many_rows then
	O_donnee(5):=0;
        O_donnee(6):='';
	End;
        Begin
        Open C_parametres2;
	Fetch C_parametres2 Into rec_C_parametres2;
	Close C_parametres2;
        O_donnee(7):=rec_C_parametres2.numfact;
	O_donnee(8):=to_char(rec_C_parametres2.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(7):=0;
	O_donnee(8):='';
	When  too_many_rows then
	O_donnee(7):=0;
        O_donnee(8):='';
	End;
        Begin
        Open C_parametres3;
	Fetch C_parametres3 Into rec_C_parametres3;
	Close C_parametres3;
        O_donnee(9):=rec_C_parametres3.numfact;
	O_donnee(10):=to_char(rec_C_parametres3.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(9):=0;
	O_donnee(10):='';
	When  too_many_rows then
	O_donnee(9):=0;
        O_donnee(10):='';
        end;
        Begin
        Open C_parametres4;
	Fetch C_parametres4 Into rec_C_parametres4;
	Close C_parametres4;
        O_donnee(11):=rec_C_parametres4.numfact;
	O_donnee(12):=to_char(rec_C_parametres4.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(11):=0;
	O_donnee(12):='';
	When  too_many_rows then
	O_donnee(11):=0;
        O_donnee(12):='';
        end;
Else
	Begin
        Open C_parametres5;
	Fetch C_parametres5 Into rec_C_parametres5;
	Close C_parametres5;
        O_donnee(3):=rec_C_parametres5.numenvoi;
	O_donnee(4):=to_char(rec_C_parametres5.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(3):=0;
	O_donnee(4):='';
	When  too_many_rows then
	O_donnee(3):=0;
        O_donnee(4):='';
        end;
	Begin
        Open C_parametres6;
	Fetch C_parametres6 Into rec_C_parametres6;
	Close C_parametres6;
        O_donnee(5):=rec_C_parametres6.numenvoi;
	O_donnee(6):=to_char(rec_C_parametres6.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(5):=0;
	O_donnee(6):='';
	When  too_many_rows then
	O_donnee(5):=0;
        O_donnee(6):='';
        end;
	Begin
        Open C_parametres7;
	Fetch C_parametres7 Into rec_C_parametres7;
	Close C_parametres7;
        O_donnee(7):=rec_C_parametres7.numenvoi;
	O_donnee(8):=to_char(rec_C_parametres7.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(7):=0;
	O_donnee(8):='';
	When  too_many_rows then
	O_donnee(7):=0;
        O_donnee(8):='';
        end;
	Begin
        Open C_parametres8;
	Fetch C_parametres8 Into rec_C_parametres8;
	Close C_parametres8;
        O_donnee(9):=rec_C_parametres8.numenvoi;
	O_donnee(10):=to_char(rec_C_parametres8.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(9):=0;
	O_donnee(10):='';
	When  too_many_rows then
	O_donnee(9):=0;
        O_donnee(10):='';
        end;
	Begin
        Open C_parametres9;
	Fetch C_parametres9 Into rec_C_parametres9;
	Close C_parametres9;
        O_donnee(11):=rec_C_parametres9.numenvoi;
	O_donnee(12):=to_char(rec_C_parametres9.datemis,'dd/mm/yyyy');
	Exception
	When no_data_found then
	O_donnee(11):=0;
	O_donnee(12):='';
	When  too_many_rows then
	O_donnee(11):=0;
        O_donnee(12):='';
        end;
End if;
	Begin
        Open C_parametres10;
	Fetch C_parametres10 Into rec_C_parametres10;
	Close C_parametres10;
	O_donnee(13):=to_char(rec_C_parametres10.sysdate,'dd/mm/yyyy');
        O_donnee(14):=rec_C_parametres10.initiales;
        O_donnee(15):=rec_C_parametres10.pseudo;
        O_donnee(16):=rec_C_parametres10.tel;
	O_donnee(17):=substr(pk_libelle.f_lib('CELL',rec_C_parametres10.cellule),1,30);
	Exception
	When no_data_found then
	O_donnee(13):=sysdate;
        O_donnee(14):='';
        O_donnee(15):='';
        O_donnee(16):='';
        O_donnee(17):='';
	When  too_many_rows then
	O_donnee(13):=sysdate;
        O_donnee(14):='';
        O_donnee(15):='';
        O_donnee(16):='';
        O_donnee(17):='';
        end;
End charge_parametres;
/
