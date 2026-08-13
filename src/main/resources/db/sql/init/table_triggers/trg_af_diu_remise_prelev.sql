CREATE TRIGGER ARTHUS.trg_af_diu_remise_prelev
   AFTER DELETE OR INSERT OR UPDATE ON remise_prelev
   REFERENCING OLD AS old NEW AS new
   FOR EACH ROW
DECLARE
   l_action       VARCHAR2(1);
BEGIN
   -- DELETE OR UPDATE (old values)
   IF DELETING OR UPDATING THEN
      IF DELETING THEN
         l_action := 'D';
      END IF;
      IF UPDATING THEN
         l_action := 'U';
      END IF;
      INSERT INTO histo_remise_prelev (
         numremise,
         numcpte,
         datrem,
         nombre,
         montant,
         valide,
         datvalide,
         datedit,
         numutil,
         datdisk,
         dataccuse,
         numutil_accuse,
         datope,
         monnaie_d,
         montant_d,
         monnaie,
         eche_prelev,
         date_prelev,
         typesepa,
         eche_prelev_sepa,
	     action_histo,
	     numutil_histo,
	     date_histo)
      VALUES (
         :old.numremise,
         :old.numcpte,
         :old.datrem,
         :old.nombre,
         :old.montant,
         :old.valide,
         :old.datvalide,
         :old.datedit,
         :old.numutil,
         :old.datdisk,
         :old.dataccuse,
         :old.numutil_accuse,
         :old.datope,
         :old.monnaie_d,
         :old.montant_d,
         :old.monnaie,
         :old.eche_prelev,
         :old.date_prelev,
         :old.typesepa,
         :old.eche_prelev_sepa,
	     l_action,
	     f_numutil,
	     SYSDATE);
   END IF;

   -- INSERT (new vlaues)
   IF INSERTING THEN
      INSERT INTO histo_remise_prelev (
         numremise,
         numcpte,
         datrem,
         nombre,
         montant,
         valide,
         datvalide,
         datedit,
         numutil,
         datdisk,
         dataccuse,
         numutil_accuse,
         datope,
         monnaie_d,
         montant_d,
         monnaie,
         eche_prelev,
         date_prelev,
         typesepa,
         eche_prelev_sepa,
	     action_histo,
	     numutil_histo,
	     date_histo)
      VALUES (
         :new.numremise,
         :new.numcpte,
         :new.datrem,
         :new.nombre,
         :new.montant,
         :new.valide,
         :new.datvalide,
         :new.datedit,
         :new.numutil,
         :new.datdisk,
         :new.dataccuse,
         :new.numutil_accuse,
         :new.datope,
         :new.monnaie_d,
         :new.montant_d,
         :new.monnaie,
         :new.eche_prelev,
         :new.date_prelev,
         :new.typesepa,
         :new.eche_prelev_sepa,
	     'I',
	     f_numutil,
	     SYSDATE);
   END IF;

   EXCEPTION WHEN OTHERS THEN NULL;
END;