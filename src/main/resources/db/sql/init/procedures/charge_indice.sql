CREATE procedure ARTHUS.charge_indice(I_debut IN date,
					  I_fin IN date,
					  I_indice IN integer,
					   O_donnee OUT pk_texte.donnee)
is
CURSOR C_indice is
select indcs.valeur,
       mone.libelle
From    indcs,
        mone,
	prmt
Where   indice=I_indice
And     mone.codmon=prmt.dfdev
And     datapli between I_debut and I_fin;
rec_C_indice C_indice%rowtype;
Begin
	Open C_indice;
	Fetch C_indice Into rec_C_indice;
	Close C_indice;
	O_donnee(1):=rec_C_indice.valeur||' '||rec_C_indice.libelle;
        O_donnee(2):=Round(((rec_C_indice.valeur*12)*8)*(3/100),0)||' '||rec_C_indice.libelle;
End charge_indice;
/
