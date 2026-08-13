CREATE TRIGGER ARTHUS.trg_bi_stock_entite_r
Before Insert
on stock_entite_r
for each row





Begin
Select seq_stock_entite_r.nextval
Into   :new.ordre
From   Dual;
End;