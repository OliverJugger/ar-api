CREATE TRIGGER ARTHUS.trg_bi_stock_entite_p
Before Insert
on stock_entite_p
for each row





Begin
Select seq_stock_entite_p.nextval
Into   :new.ordre
From   Dual;
End;