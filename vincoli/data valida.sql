drop trigger if exists Controlladata;
delimiter $$

create trigger ControllaData
before insert on Utente
for each row
BEGIN
	if new.DataIscrizione>current_date() then
		signal sqlstate '45000'
        set message_text = 'Data non valida';
   end if;     
END$$
