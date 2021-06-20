drop trigger if exists ControllaFlessibilita;
delimiter $$

create trigger ControllaFlessibilita
before insert on Prenotazione
for each row
BEGIN
	if new.Variazione<>NULL then
	begin
		declare flex tinyint default 0;
        declare _entita smallint default 0;
        
        select P.Flessibilità into flex
        from Pool P
        where P.IdPool=new.Pool;
        
        if flex=0 then
			signal sqlstate '45000'
            set message_text='Questo pool non prevede variazioni';
        
        else 
			select Entita into _entita
            from Variazione
            where CodVariazione=new.Variazione;
            
            if (_entita/5)>=flex then 
				signal sqlstate '45000'
				set message_text='Questa variazione supera il livello di flessibilità del pool';
            end if;
            
        end if;    
    end;    
	end if;	
END$$