CREATE Function ARTHUS.f_contact (
			a_numindiv 	in Number,
			a_nature 	in Number 	Default 1
			)
Return varchar2
Is

Cursor Fetch_Contact Is
	SELECT ALL CONTACT.COORDONNEE
		FROM CONTACT
		WHERE (CONTACT.NUMINDIV = a_numindiv
		AND CONTACT.NATURE = a_nature) ;
R_Contact	Fetch_Contact%Rowtype;
Begin
	open Fetch_Contact;
	Fetch Fetch_Contact INTO R_Contact;
	IF Fetch_Contact%NOTFOUND THEN
		return(NULL);
	ELSE
		return(R_Contact.COORDONNEE);
	END IF;
	Close Fetch_Contact;
	EXCEPTION
		WHEN OTHERS THEN return('Coordonnées erronées ');
End f_contact;
