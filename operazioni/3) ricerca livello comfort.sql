
-- CALCOLO LIVELLO COMFORT(RIDONDANZA)

drop function if exists LivelloComfort;
delimiter $$
create function LivelloComfort(_targa varchar(7))
	returns float not deterministic 
BEGIN

	declare livelloComfort float default 1;
	declare error_targa tinyint default null;
    
    select count(*) into error_targa
		from autovettura 
        where targa = _targa;
        
	if error_targa is null then
		signal sqlstate '45000'
		set message_text = 'Autovettura non esistente';
    end if;
    
	select sum(pesoComfort) into livelloComfort
		from equipaggiamento E
			inner join optional O on O.codOptional = E.optional
		where E.autovettura = _targa
        group by E.autovettura;
        
        if livelloComfort < 1 or  livelloComfort is null then
			return 1;
		end if;
        
		if livelloComfort > 5 then
			return 5;
		end if;
        
		return round(livelloComfort,2);
END$$
delimiter ;

-- RICERCA LIVELLO COMFORT
select LivelloComfort
from Autovettura
where Proprietario='RSSVLN78E140715B' -- utente di esempio