CREATE TRIGGER ARTHUS."TRG_AF_DEL_ADHE_CNTRT"
AFTER DELETE ON adhe_cntrt
FOR EACH ROW
DECLARE
  --
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
  --
BEGIN

  delete 	histo_adhesion
	where	idadhesion = :old.idadhesion;

  delete 	adhe_cntrt_membre
	where	idadhesion = :old.idadhesion;


  Delete	apporteur
	Where	etendue = 4
	and	cle = :old.idadhesion;

  	/* CTT 14/03/2008 : Delete dans porte_adhesion  (cascade sur noemie) */
	Delete  porte_adhesion
	Where 	idadhesion 	= :old.idadhesion
	And		transmis	= 2;

  /*SDA MAntis 4957 */
  --on eface le mandat dans histo_mandat
  Delete from histo_mandat where histo_mandat.mandat in (select mandat from histo_querable where idadhesion = :old.idadhesion);

  --on efface le mandat dans histo_querable
  Delete histo_querable where	idadhesion = :old.idadhesion;


END;