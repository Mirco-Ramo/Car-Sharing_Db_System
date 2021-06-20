-- RILEVA SINISTRI

drop procedure if exists rilevaSinistro;
delimiter $$
create procedure rilevaSinistro(in _codice varchar(8), in _istante timestamp, in _dinamica text,
							    in _risolto varchar(2), _entita tinyint, in _ruolo varchar(10),in _conducente varchar(16),
                                in _auto varchar(7))
BEGIN 
  
	if _istante > current_timestamp() then
		signal sqlstate '45000'
			set message_text = 'Timestamp non valido';
	end if;
   
	if _risolto not in('si','no') then
		signal sqlstate '45000'
			set message_text = 'Dati non validi';
	end if;
  
	if _conducente not in(select codFiscale from utente) then
		signal sqlstate '45000'
			set message_text = 'Codice fiscale non valido';
	end if;

	if _ruolo not in ('Colpevole','Non colpevole','Concorrente di colpa') then
     	signal sqlstate '45000'
			set message_text = 'Ruolo non valido';
	end if;   
	
    if _auto not in(select targa from autovettura) then
		signal sqlstate '45000'
			set message_text = 'Targa non valida';
	end if;
  
	if _entita not between 1 and 3 then
		signal sqlstate '45000'
			set message_text = 'Entità non valida';
	end if;
	
	if (_ruolo = 'Colpevole' or  _ruolo ='Concorrente di colpa') and _risolto = 'no' then
		update account
			set stato = 'Inattivo'
            where utente = _conducente;
	end if;
    
    if _risolto = 'no' then
		update fruibilita
			set esigenzeParticolari = 'si'
			where autovettura = _auto;
	end if;
    
    insert into sinistro values(_codice,_istante,_dinamica,_risolto,_entita,_ruolo,_conducente,_auto);
       
END$$

delimiter ;