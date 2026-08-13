CREATE procedure ARTHUS.p_refsin IS
---
--
G_norisq_max	sntr_prev.norisq%type;
G_norisq	sntr_prev.norisq%type;
G_ref_ext_1	sntr_prev.ref_ext_1%type;
G_ref_ext_2	sntr_prev.ref_ext_2%type:=0;
Compteur	number(10);
--
Cursor c_sntr(I_norisq number) IS
	select *
	from sntr_prev
	where norisq = I_norisq
	for update of ref_ext_1, ref_ext_2;
--
Rec_c_sntr	c_sntr%rowtype;
--
---
Begin
--
--
select max(norisq)
into G_norisq_max
from sntr_prev;
--
For G_norisq IN 1 .. 6
Loop
--
      Begin
        select libelle
        into   G_ref_ext_1
        from   lble
        where  mnemo = 'REF_SNTR'
        and    code  = G_norisq;
      End;
--
	Open c_sntr(G_norisq);
	Loop
		Fetch c_sntr into Rec_c_sntr;
		Exit when c_sntr%notfound;
		G_ref_ext_2 := nvl(G_ref_ext_2,0) + 1;
		Update sntr_prev s
		Set 	s.ref_ext_1 = G_ref_ext_1,
			s.ref_ext_2 = G_ref_ext_2
		Where current of c_sntr;
--
    DBMS_OUTPUT.PUT_LINE(Rec_c_sntr.nosin);
--
	End Loop;
	Close c_sntr;
--
    DBMS_OUTPUT.PUT_LINE(to_char(G_norisq));
    DBMS_OUTPUT.PUT_LINE(G_ref_ext_1);
    DBMS_OUTPUT.PUT_LINE(to_char(G_ref_ext_2));
--
G_ref_ext_2 := 0;
--
End Loop;
--
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERREUR');
--
End;
/
