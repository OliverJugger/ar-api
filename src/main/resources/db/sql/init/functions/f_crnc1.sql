CREATE function ARTHUS.f_crnc1 (f_idadhesion IN NUMBER)
RETURN number
IS
test_famille NUMBER;
test_ad01 NUMBER;
test_dfrb NUMBER;
BEGIN
	begin
	select count(distinct dfrb.codfrais)
	into test_dfrb
	from dfrb,adhesion,adhe_cntrt
	where adhe_cntrt.idadhesion=f_idadhesion
	and adhesion.numgar=adhe_cntrt.numgar
	and adhesion.idadhesion=adhe_cntrt.idadhesion
	and adhesion.numfor=dfrb.numfor
	and adhesion.datapli!=nvl(adhesion.datper,adhesion.datapli+1)
	and dfrb.datapli!=nvl(dfrb.datper,dfrb.datapli+1)
	and nvl(adhesion.datper,sysdate)>=sysdate
	and dfrb.datapli between adhesion.datapli
	                      and nvl(adhesion.datper,to_date('3000','YYYY'));
	select count(distinct codfrais)
	into test_ad01
	from v_trav_ad01
	where v_trav_ad01.idadhesion=f_idadhesion;
if(test_ad01=test_dfrb)
	then
	select 1
	into test_famille
	from
	 v_trav_ad01
 	 where v_trav_ad01.idadhesion=f_idadhesion
	 and v_trav_ad01.datapli<=sysdate;
	else
	return(1);
	end if;
		EXCEPTION
		when no_data_found then return(0);
		when too_many_rows then return(1);
	end;
RETURN(test_famille);
END f_crnc1;
