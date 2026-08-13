CREATE procedure ARTHUS.charge_echeancier ( I_cle IN pk_texte.clefs,
						O_donnee OUT pk_texte.donnee)
is
CURSOR C_echeancier is
select v_echeancier.montant,
       v_echeancier.mt_regl,
       v_echeancier.eecheance
From   v_echeancier
Where  v_echeancier.numquit=I_cle(1)
Group By v_echeancier.eecheance;
rec_C_echeancier C_echeancier%rowtype;
BEGIN
	Open C_echeancier;
	Fetch C_echeancier Into rec_C_echeancier;
	Close C_echeancier;
	O_donnee(1):=(rec_C_echeancier.montant-nvl(rec_C_echeancier.mt_regl,0));
	O_donnee(2):=rec_C_echeancier.eecheance;
END charge_echeancier;
/
