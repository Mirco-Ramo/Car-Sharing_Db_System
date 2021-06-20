drop trigger if exists VerificaAccount;
delimiter $$

create trigger VerificaAccount
after update on Documento for each row
BEGIN 
	declare confermato varchar(2);
    
    select D.Verificato into confermato
    from Documento D
    where Tipologia=new.Tipologia and NumDocumento=new.NumDocumento;
    
    if confermato='si' then
		update Account
		set Stato='verificato'
		where Utente=new.Utente;
    end if;
    
END$$

delimiter ;

drop trigger if exists BloccaAutoUtentiNonConfermati;
delimiter $$

create trigger  BloccaAutoUtentiNonConfermati
before insert on Autovettura for each row
BEGIN 
	declare confermato varchar(2);
    
    select D.Verificato into confermato
    from Autovettura A inner join Documento D on A.Proprietario=D.Utente
    where D.Utente=new.Proprietario;
    
    if confermato='no' then
		signal sqlstate '45000'
		set message_text = 'Utente con documento non verificato';
    end if;
    
END$$

delimiter ;

drop trigger if exists BloccaCarSharingUtentiNonConfermati;
delimiter $$

create trigger  BloccaCarSharingUtentiNonConfermati
before insert on CarSharing for each row
BEGIN 
	declare confermato varchar(2);
    
    select D.Verificato into confermato
    from CarSharing Cs inner join Documento D on Cs.fruitore=D.Utente
    where D.Utente=new.Fruitore
    group by D.Utente, D.Verificato;
    
    if confermato='no' then
		signal sqlstate '45000'
		set message_text = 'Utente con documento non verificato';
    end if;
    
END$$

delimiter ;

drop trigger if exists BloccaPoolUtentiNonConfermati;
delimiter $$

create trigger  BloccaPoolUtentiNonConfermati
before insert on Prenotazione for each row
BEGIN 
	declare confermato varchar(2);
    
    select D.Verificato into confermato
    from Prenotazione P inner join Documento D on P.Fruitore=D.Utente
    where D.Utente=new.Fruitore
    group by D.Utente, D.Verificato;
    
    if confermato='no' then
		signal sqlstate '45000'
		set message_text = 'Utente con documento non verificato';
    end if;
    
END$$

delimiter ;

drop trigger if exists BloccaRideSharingUtentiNonConfermati;
delimiter $$

create trigger  BloccaRideSharingUtentiNonConfermati
before insert on Chiamata for each row
BEGIN 
	declare confermato varchar(2);
    
    select D.Verificato into confermato
    from Chiamata C inner join Documento D on C.fruitore=D.Utente
    where D.Utente=new.Fruitore
    group by D.Utente, D.Verificato;
    
    if confermato='no' then
		signal sqlstate '45000'
		set message_text = 'Utente con documento non verificato';
    end if;
    
END$$

delimiter ;