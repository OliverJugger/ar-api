CREATE FUNCTION ARTHUS.f_cvrtsante(
			i_numindiv in number,
			i_datsin in date default null)
RETURN 	number
AS
loc_retour number default 0;
BEGIN
		Select	1
		Into	loc_retour
		From	adhesion
		Where	adhesion.numindiv = i_numindiv
		and		nvl(i_datsin, adhesion.datapli)
				between adhesion.datapli
				and     nvl(adhesion.datper,nvl(i_datsin, adhesion.datapli))
		and		adhesion.datapli != nvl(adhesion.datper, adhesion.datapli + 1)
		and		adhesion.typfor = 1
		Union
		Select	1
		From	grp_gar_def,
				adhesion
		Where	grp_gar_def.numgrpgar = adhesion.numfor
		and		adhesion.numindiv = i_numindiv
		and		nvl(i_datsin, adhesion.datapli)
				between adhesion.datapli
				and     nvl(adhesion.datper,nvl(i_datsin, adhesion.datapli))
		and		adhesion.datapli != nvl(adhesion.datper, adhesion.datapli + 1)
		and		adhesion.typfor = 3
		and		grp_gar_def.typfor = 1
		;
		return loc_retour;
Exception
		When No_data_found 	then return 0;
		When too_many_rows 	then return 1;
		When others 		then return 0;
END f_cvrtsante;
