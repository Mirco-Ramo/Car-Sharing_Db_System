-- AGGIORNAMENTO STATO VALIDITÀ POOL

drop event if exists aggiornaStato;
delimiter $$

create event aggiornaStato 
	on schedule every 15 minute starts '2018-12-06 01:00:00'
do
BEGIN
	declare finito integer default 0;
	declare varPool varchar(10);
    
	declare listaPool cursor for
		select idPool from pool
			where validita >= 0.25;
    
    declare continue handler for not found
		set finito = 1;
        
	open listaPool;
     
	ciclo_aggiorna: loop
    
		fetch listaPool into varPool;
        
        if finito = 1 then
			leave ciclo_aggiorna;
		end if;
        
        update pool
			set validita = validita - 0.25 -- 0.25 equivale a 15 minuti
			where  idpool = varPool;
    
	end loop;
	close listaPool;
	
END$$
delimiter ; 
