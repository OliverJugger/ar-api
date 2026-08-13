CREATE function ARTHUS.f_rep_imp_exp
(p_directory_name in varchar2, p_I_E in varchar2, p_type_traitement in varchar2 default NULL)
	return varchar2
as
/*
** Détermination du "Directory PATH" ou du "Directory NAME"
     Argument p_I_E : Paramètres informatifs - A utiliser ultérieusement si besoin
	 P pour PURGE, I pour import, E pour export
*/
	v_directory_name		all_directories.DIRECTORY_NAME%type;
	v_directory_path 		all_directories.DIRECTORY_PATH%type;
	v_lg					number(5);
--
	cursor c_all_directories is
	select DIRECTORY_PATH, DIRECTORY_NAME from all_directories
	where  DIRECTORY_NAME = upper(p_directory_name);
--
Begin
--
v_directory_path := NULL;
v_directory_name := NULL;
--
/* Récupération du directory path dans la table all_directories */
Open c_all_directories;
Fetch c_all_directories into v_directory_path, v_directory_name;
--
If c_all_directories%NOTFOUND THEN
--
	Close c_all_directories;
	--
	return null;
--
ELSE
--
	if (p_type_traitement = 'PKG') THEN
		-- return name pour les packages
		Close c_all_directories;
		--
		return(v_directory_name);
	else
		-- return path pour les DLL
		v_lg := length(v_directory_path);
		--
		/* Ajout de l'antislash si il n'est pas présent à la fin du répertoire */
		If NOT (substr(v_directory_path, v_lg,v_lg) = '\') then
			v_directory_path := v_directory_path||'\';
		End if;
		--
		Close c_all_directories;
		--
		return(v_directory_path);
		--
	end if;
--
END IF;
--
Exception
	when others then
		-- FERMETURE du Curseur
		IF c_all_directories%ISOPEN THEN
			CLOSE c_all_directories;
		END IF;
		--
		return null;
--
End f_rep_imp_exp;
