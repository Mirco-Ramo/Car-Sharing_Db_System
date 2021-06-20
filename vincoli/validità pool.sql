drop trigger if exists ControllaValiditaMInPool;
delimiter $$

create trigger ControllaValiditaMinPool
before insert on Pool
for each row
BEGIN
	if new.Validita<48 then
		signal sqlstate '45000'
        set message_text='Inserire un periodo di validita di almeno 48 ore';
    end if;    
END$$

delimiter ;
drop trigger if exists BloccaPrenotazioniTarde;
delimiter $$
create trigger BloccaPrenotazioniTarde
before insert on Prenotazione
for each row
BEGIN
	declare validitaRimasta float;
    
    select P.Validita into validitaRimasta
    from  Pool P
    where P.IdPool=new.Pool;
    
    if validitaRimasta<1 then
		signal sqlstate '45000'
        set message_text='La prenotazione è scaduta';
    end if;
    
END$$
