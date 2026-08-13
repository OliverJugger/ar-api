CREATE function ARTHUS.f_age (
				a_datnais	In Date,
				a_datjour	In Date Default Sysdate
				)
Return Number
Is
BEGIN
Return	( Floor(Months_between(a_datjour, a_datnais) / 12) );
END	f_age;
