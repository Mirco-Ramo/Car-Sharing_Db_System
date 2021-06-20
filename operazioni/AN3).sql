drop procedure if exists TempoDiArrivoEffettivo;
delimiter $$

create procedure TempoDiArrivoEffettivo(in _Evento varchar(10))
BEGIN
	declare Chiave tinyint default 0;
    declare Tipo tinyint default 0;
    case substring(_Evento,1, 2)
		when 'CP' then
			select count(*)into Chiave
			from Pool
			where IdPool=_Evento;
			set Tipo=1;
        
		when 'RS' then
			select count(*) into Chiave
			from RideSharing
			where IdRide=_Evento;
            set Tipo=2;
            
		else signal sqlstate '45000'
			set message_text='Chiave evento non valida';
		end case;
    
    if Chiave=0 then
		 signal sqlstate '45000'
		 set message_text='Evento non trovato'; 
    end if;
    
    if Tipo=1 then
    begin
    select D.Pool, D.CodStrada, D.KmStrada, round(D.TempoAttuale,2), D.Ordine, 
		  D.Partenza + interval @somma*60 +least(0, @tempo:=@tempo+D.TempoAttuale)+least(0, @somma:=@tempo) second as ArrivoPrevisto
     from(
		   select TP.pool,T.codStrada,T.kmStrada,TempoIstantaneo(T.CodStrada, T.KmStrada) as TempoAttuale,TP.ordine,
			(select partenzaprevista from pool where idPool = _Evento)
			as Partenza
			from (tragittoPool TP 
					inner join tratto T
				on TP.strada=T.codStrada) 
				where 
						((T.kmStrada >= TP.KmInizio and T.kmStrada <=TP.KmFine)
					or 
						(T.kmStrada <= TP.KmInizio and T.kmStrada >=TP.KmFine))
					and TP.pool = _Evento
					order by TP.ordine,kmStrada
          )as D, (select @somma:=0) as N, (select@tempo:=0) as M;
    end;
    else
    begin
	select D.RideSharing, D.CodStrada, D.KmStrada, round(D.TempoAttuale,2), D.Ordine, 
		  D.Partenza + interval @somma*60 +least(0, @tempo:=@tempo+D.TempoAttuale)+least(0, @somma:=@tempo) second as ArrivoPrevisto
     from(
		   select TR.RideSharing,T.codStrada,T.kmStrada,TempoIstantaneo(T.CodStrada, T.KmStrada) as TempoAttuale,TR.ordine,
			(select TsInizio from RideSharing where idRide = _Evento)
			as Partenza
			from (tragittoRide TR 
					inner join tratto T
				on TR.strada=T.codStrada) 
				where 
						((T.kmStrada >= TR.KmInizio and T.kmStrada <=TR.KmFine)
					or 
						(T.kmStrada <= TR.KmInizio and T.kmStrada >=TR.KmFine))
					and TR.RideSharing = _Evento
					order by TR.ordine,kmStrada
          )as D, (select @somma:=0) as N, (select@tempo:=0) as M;	
    end;
    end if;
    
END$$
delimiter ;
call TempoDiArrivoEffettivo('RS1');
call arrivoPrevistoPool('RS1');