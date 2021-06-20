-- RAFFINAMENTO TEMPI MEDI DI PERCORRENZA

drop event if exists RaffinamentoTempiMedi;
delimiter $$
create event RaffinamentoTempiMedi
	on schedule every 15 day starts '2018-12-06 02:00:00'
do
BEGIN
	declare finito tinyint default 0;
	declare strada varchar(10);
    declare km smallint;
    declare lunghezza float;
    declare velMedia float default null;
    
    declare ListaTratti cursor for
		select CodStrada,KmStrada,Lunghezza from tratto; -- Consideriamo ogni tratto
        
	declare continue handler for not found
        set finito=1;
        
	open ListaTratti;
    
	ciclo_aggiorna: loop -- Per ogni tratto si esegue l'aggiornamento
    
		fetch ListaTratti into strada,km,lunghezza; -- Ricavo tratto
      
		if finito = 1 then -- Controllo uscita dal ciclo
			leave ciclo_aggiorna;
		end if;
        
        -- Ricavo il tempo di percorrenza medio dell'ultimo anno di tutte le auto
		select avg(T.VelocitaMedia) into velMedia
        from tracking T
			where T.timestamp >= (current_timestamp() - interval 1 year)
				and CodStrada = strada and KmStrada = km
		group by codStrada,KmStrada
			having count(distinct T.Autovettura) >= 20;
            
		-- Se vi sono passate almeno 20 auto diverse si aggiorna
		if velMedia is not null then
			update tratto T 
				set T.tempoMedioPercorrenza = round((lunghezza/velMedia)*60,2)
			where  T.codStrada = strada and 
				   T.kmStrada = km;
		end if;
        
	end loop ciclo_aggiorna;
    
    close ListaTratti;
    
END$$
delimiter ;

