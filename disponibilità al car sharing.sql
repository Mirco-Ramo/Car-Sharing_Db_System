drop trigger if exists ControllaFruibilita;
delimiter $$

create trigger ControllaFruibilita
before insert on CarSharing
for each row
BEGIN
	declare occupata tinyint default 0;
    declare fruibile tinyint default 0;
    declare dataInizio date;
    declare DataFine date;
    
    set DataInizio=cast(new.InizioProgrammato as date);
    set DataFine=cast(new.FineProgrammata as date);
    
    case 
		when dayofweek(DataInizio)=1 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Domenica' and 
                  DataInizio between F.OraInizio and F.OraFine and
                   DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;  
		
        when dayofweek(DataInizio)=2 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Lunedì' and 
                  DataInizio between F.OraInizio and F.OraFine and
				  DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;
        
        when dayofweek(DataInizio)=3 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Martedì' and 
                  DataInizio between F.OraInizio and F.OraFine and
                   DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;
    
		when dayofweek(DataInizio)=4 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Mercoledì' and 
                  DataInizio between F.OraInizio and F.OraFine and
                   DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;
        
        when dayofweek(DataInizio)=5 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Giovedì' and 
                  DataInizio between F.OraInizio and F.OraFine and
                   DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;
            
        when dayofweek(DataInizio)=6 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Venerdì' and 
                  DataInizio between F.OraInizio and F.OraFine and
                   DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;   
         
         when dayofweek(DataInizio)=7 then 
			select count(*) into fruibile  
			from Fruibilita F 
            where F.Autovettura=new.Autovettura and
                  F.Giorno='Sabato' and 
                  DataInizio between F.OraInizio and F.OraFine and
                   DataFine between F.OraInizio and F.OraFine;
                  
            if fruibile=0 then
				signal sqlstate '45000'
				set message_text='Auto non fruibile in questa fascia oraria'; 
            end if;
         
         end case;
         
         select count(*) into occupata
         from CarSharing CS
         where CS.Auvettura=new.Autovettura and
			   (new.InizioProgrammato between Cs.InizioProgrammato and Cs.FineProgrammata or
                new.FineProgrammata between Cs.InizioProgrammato and Cs.FineProgrammata);
         
         if occupata>0 then
			signal sqlstate '45000'
            set message_text= 'Auto già prenotata';
         end if;

         select count(*) into occupata
         from Fruibilita
         where Autovettura=new.Autovettura and EsigenzeParticolari='si';
         
         if occupata>0 then
			signal sqlstate '45000'
            set message_text= 'Per esigenze straordinarie questa auto del proprietario, questa auto non è al momento fruibile';
         end if;
         
         
         
END$$