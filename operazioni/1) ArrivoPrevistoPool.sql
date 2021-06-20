-- ARRIVO PREVISTO IN OGNI TRATTO DEL POOL

drop procedure if exists arrivoPrevistoPool;
delimiter $$

create procedure arrivoPrevistoPool(in _pool varchar(10))
BEGIN
	select D.Pool, D.CodStrada, D.KmStrada, D.TempoMedioPercorrenza, D.Ordine, 
		  D.Partenza + interval @somma*60 +least(0, @tempo:=@tempo+D.TempoMedioPercorrenza)+least(0, @somma:=@tempo) second as ArrivoPrevisto
    from(
		select TP.pool,T.codStrada,T.kmStrada,T.TempoMedioPercorrenza,TP.ordine,
			(select partenzaprevista from pool where idPool = _pool)
			as Partenza
			from (tragittoPool TP 
					inner join tratto T
				on TP.strada=T.codStrada) 
				where 
						((T.kmStrada >= TP.KmInizio and T.kmStrada <=TP.KmFine)
					or 
						(T.kmStrada <= TP.KmInizio and T.kmStrada >=TP.KmFine))
					and TP.pool = _pool
					order by TP.ordine,kmStrada
           )as D,(select @tempo:=0) as N, (select @somma:=0) as M;    
END$$

delimiter ;

call arrivoPrevistoPool('CP2');
