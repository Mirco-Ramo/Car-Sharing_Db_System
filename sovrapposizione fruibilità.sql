drop trigger if exists FruibilitaInvalida;
delimiter $$

create trigger FruibilitaInvalida
before insert on Fruibilita
for each row
BEGIN
    declare sovrapposta tinyint default 0;
    
    select count(*) into sovrapposta
    from Fruibilita F
    where F.Giorno=new.Giorno and
		  F.Autovettura=new.Autovettura and
          ((new.OraInizio between F.OraInizio and F.OraFine or
             new.OraFine between F.OraInizio and F.OraFine) or
		    (F.OraInizio between new.OraInizio and new.OraFine or
			 F.OraFine between new.OraInizio and new.OraFine));
    if sovrapposta>0 then
		signal sqlstate '45000'
        set message_text='Orario non valido';
    end if;    
    
END$$
