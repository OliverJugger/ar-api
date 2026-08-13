CREATE TRIGGER ARTHUS.trg_bi_stock_entite
Before Insert
on stock_entite
for each row





Begin
Select seq_stock_entite.nextval
Into   :new.ordre
From   Dual;
End;