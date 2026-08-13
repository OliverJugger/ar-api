CREATE function ARTHUS.f_existe_valeur (
				a_objet 	in number,
				a_debut 	in date,
				a_type		in number default 1,
				a_numorg	in number default 0,
				a_codfrais	in varchar2 default null
				)
Return Date
As
loc_retour	Date;
Cursor fetch_indice is
	Select	indice.datapli
	From	indice
	Where	indice.indice = a_objet
	and	a_debut between indice.datapli
			and nvl(indice.datper, a_debut);
Cursor fetch_tarif is
	Select	tarif.datapli
	From	tarif
	Where	tarif.typtar = a_objet
	And	tarif.numorg=a_numorg
	And	tarif.codfrais=a_codfrais
	and	a_debut between tarif.datapli
			and nvl(tarif.datper, a_debut);
Cursor fetch_dfrb is
	Select	dfrb.datapli
	From	dfrb
	Where	dfrb.numfor = a_objet
	And	dfrb.codfrais=a_codfrais
	and	a_debut between dfrb.datapli
			and nvl(dfrb.datper, a_debut);
Cursor fetch_calcul is
	Select	calcul.datapli
	From	calcul
	Where	calcul.numfor = a_objet
	And	calcul.codfrais=a_codfrais
	and	a_debut between calcul.datapli
			and nvl(calcul.datper, a_debut);
Cursor fetch_franact is
	Select	franact.datapli
	From	franact
	Where	franact.numfor = a_objet
	And	franact.codfrais=a_codfrais
	and	a_debut between franact.datapli
			and nvl(franact.datper, a_debut);
Cursor fetch_maxact is
	Select	maxact.datapli
	From	maxact
	Where	maxact.numfor = a_objet
	And	maxact.codfrais=a_codfrais
	and	a_debut between maxact.datapli
			and nvl(maxact.datper, a_debut);
Cursor fetch_crnc is
	Select	crnc.datapli
	From	crnc
	Where	crnc.numfor = a_objet
	And	crnc.codfrais=a_codfrais
	And	nvl(crnc.nummath,0)=a_numorg
	and	a_debut between crnc.datapli
			and nvl(crnc.datper, a_debut);
Cursor fetch_franfor is
	Select	franfor.datapli
	From	franfor
	Where	franfor.numfor = a_objet
	and	a_debut between franfor.datapli
			and nvl(franfor.datper, a_debut);
Cursor fetch_maxfor is
	Select	maxfor.datapli
	From	maxfor
	Where	maxfor.numfor = a_objet
	and	a_debut between maxfor.datapli
			and nvl(maxfor.datper, a_debut);
Cursor fetch_cond_adhesion_gar is
	Select	cond_adhesion_gar.debut
	From	cond_adhesion_gar
	Where	cond_adhesion_gar.numfor = a_objet
	And	cond_adhesion_gar.valide='O'
	and	a_debut between cond_adhesion_gar.debut
			and nvl(cond_adhesion_gar.fin, a_debut);
Cursor fetch_frml_prime_simple is
	Select	frml_prime_simple.debut
	From	frml_prime_simple
	Where	frml_prime_simple.numfor = a_objet
	And	frml_prime_simple.base=a_numorg
	And	nvl(frml_prime_simple.taux,a_codfrais)=a_codfrais
	And	frml_prime_simple.valide='O'
	and	a_debut between frml_prime_simple.debut
			and nvl(frml_prime_simple.fin, a_debut);
Cursor fetch_cond_adhesion is
	Select	cond_adhesion.debut
	From	cond_adhesion
	Where	cond_adhesion.cle = a_objet
	And	cond_adhesion.etendue=a_numorg
	And	cond_adhesion.valide='O'
	and	a_debut between cond_adhesion.debut
			and nvl(cond_adhesion.fin, a_debut);
Cursor fetch_frml_tfc is
	Select	frml_tfc.debut
	From	frml_tfc
	Where	frml_tfc.numfor = a_objet
	And	frml_tfc.type_tfc=a_numorg
	And	frml_tfc.valide='O'
	And	frml_tfc.tfc=a_codfrais
	and	a_debut between frml_tfc.debut
			and nvl(frml_tfc.fin, a_debut);
Cursor fetch_cond_proposition is
	Select	cond_proposition.debut
	From	cond_proposition
	Where	cond_proposition.cle = a_objet
	And	cond_proposition.etendue=a_numorg
	And	cond_proposition.valide='O'
	and	a_debut between cond_proposition.debut
			and nvl(cond_proposition.fin, a_debut);
Cursor fetch_cond_souscription is
	Select	cond_souscription.debut
	From	cond_souscription
	Where	cond_souscription.numprod = a_objet
	And	cond_souscription.valide='O'
	and	a_debut between cond_souscription.debut
			and nvl(cond_souscription.fin, a_debut);
Cursor fetch_frml_prest is
	Select	frml_prest.debut
	From	frml_prest
	Where	frml_prest.numfor = a_objet
	And	frml_prest.valide='O'
	and	a_debut between frml_prest.debut
			and nvl(frml_prest.fin, a_debut);
Cursor fetch_frml_reval is
	Select	frml_reval.debut
	From	frml_reval
	Where	frml_reval.numfor = a_objet
	And	frml_reval.valide='O'
	and	a_debut between frml_reval.debut
			and nvl(frml_reval.fin, a_debut);
Cursor fetch_frml_dedu is
	Select	frml_dedu.debut
	From	frml_dedu
	Where	frml_dedu.numfor = a_objet
	And	frml_dedu.valide='O'
	And	frml_dedu.typdedu=a_numorg
	and	a_debut between frml_dedu.debut
			and nvl(frml_dedu.fin, a_debut);
loc_indice	fetch_indice%Rowtype;
loc_tarif	fetch_tarif%Rowtype;
loc_dfrb	fetch_dfrb%Rowtype;
loc_calcul	fetch_calcul%Rowtype;
loc_franact	fetch_franact%Rowtype;
loc_maxact	fetch_maxact%Rowtype;
loc_crnc	fetch_crnc%Rowtype;
loc_franfor	fetch_franfor%Rowtype;
loc_maxfor	fetch_maxfor%Rowtype;
loc_cond_adhesion_gar	fetch_cond_adhesion_gar%Rowtype;
loc_frml_prime_simple	fetch_frml_prime_simple%Rowtype;
loc_cond_adhesion	fetch_cond_adhesion%Rowtype;
loc_frml_tfc	fetch_frml_tfc%Rowtype;
loc_cond_proposition	fetch_cond_proposition%Rowtype;
loc_cond_souscription	fetch_cond_souscription%Rowtype;
loc_frml_prest	fetch_frml_prest%Rowtype;
loc_frml_reval	fetch_frml_reval%Rowtype;
loc_frml_dedu	fetch_frml_dedu%Rowtype;
BEGIN
loc_retour := Null;
If (a_type=1) then
	For loc_indice in fetch_indice
	loop
		loc_retour := loc_indice.datapli;
		Exit;
	end loop;
Elsif (a_type=2)
then
	For loc_tarif in fetch_tarif
	loop
		loc_retour := loc_tarif.datapli;
		Exit;
	end loop;
Elsif (a_type=3)
then
	For loc_dfrb in fetch_dfrb
	loop
		loc_retour := loc_dfrb.datapli;
		Exit;
	end loop;
Elsif (a_type=4)
then
	For loc_calcul in fetch_calcul
	loop
		loc_retour := loc_calcul.datapli;
		Exit;
	end loop;
Elsif (a_type=5)
then
	For loc_franact in fetch_franact
	loop
		loc_retour := loc_franact.datapli;
		Exit;
	end loop;
Elsif (a_type=6)
then
	For loc_maxact in fetch_maxact
	loop
		loc_retour := loc_maxact.datapli;
		Exit;
	end loop;
Elsif (a_type=7)
then
	For loc_crnc in fetch_crnc
	loop
		loc_retour := loc_crnc.datapli;
		Exit;
	end loop;
Elsif (a_type=8)
then
	For loc_franfor in fetch_franfor
	loop
		loc_retour := loc_franfor.datapli;
		Exit;
	end loop;
Elsif (a_type=9)
then
	For loc_maxfor in fetch_maxfor
	loop
		loc_retour := loc_maxfor.datapli;
		Exit;
	end loop;
Elsif (a_type=10)
then
	For loc_cond_adhesion_gar in fetch_cond_adhesion_gar
	loop
		loc_retour := loc_cond_adhesion_gar.debut;
		Exit;
	end loop;
Elsif (a_type=11)
then
	For loc_frml_prime_simple in fetch_frml_prime_simple
	loop
		loc_retour := loc_frml_prime_simple.debut;
		Exit;
	end loop;
Elsif (a_type=12)
then
	For loc_cond_adhesion in fetch_cond_adhesion
	loop
		loc_retour := loc_cond_adhesion.debut;
		Exit;
	end loop;
Elsif (a_type=13)
then
	For loc_frml_tfc in fetch_frml_tfc
	loop
		loc_retour := loc_frml_tfc.debut;
		Exit;
	end loop;
Elsif (a_type=14)
then
	For loc_cond_proposition in fetch_cond_proposition
	loop
		loc_retour := loc_cond_proposition.debut;
		Exit;
	end loop;
Elsif (a_type=15)
then
	For loc_cond_souscription in fetch_cond_souscription
	loop
		loc_retour := loc_cond_souscription.debut;
		Exit;
	end loop;
Elsif (a_type=16)
then
	For loc_frml_prest in fetch_frml_prest
	loop
		loc_retour := loc_frml_prest.debut;
		Exit;
	end loop;
Elsif (a_type=17)
then
	For loc_frml_reval in fetch_frml_reval
	loop
		loc_retour := loc_frml_reval.debut;
		Exit;
	end loop;
Elsif (a_type=18)
then
	For loc_frml_dedu in fetch_frml_dedu
	loop
		loc_retour := loc_frml_dedu.debut;
		Exit;
	end loop;
End if;
Return ( loc_retour );
END	f_existe_valeur;
