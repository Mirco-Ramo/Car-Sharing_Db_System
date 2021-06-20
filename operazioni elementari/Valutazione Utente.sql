-- VALUTAZIONE UTENTE

drop procedure if exists aggiungiValutazione;
delimiter $$
create procedure aggiungiValutazione(in _votante varchar(16), in _votato varchar(16), 
									 in _data date, _tipo varchar(4),in _comportamento tinyint,
                                     in _serieta tinyint, in _piacereViaggio tinyint, 
                                     in _puntualita tinyint, in _sicurezza tinyint, in _recensione text)
BEGIN 
	if _votante not in(select codFiscale from utente) or
	   _votato not in(select codFiscale from utente) or
       _votato = _votante
	then
		signal sqlstate '45000'
			set message_text = 'Codice fiscale non valido';
	end if;
    
	if(_data > current_date()) then
		signal sqlstate '45000'
			set message_text = 'Data non valida';
    end if;
    
	if _tipo not in('pool','ride','car') then
		signal sqlstate '45000'
			set message_text = 'Tipo evento non valido';
	end if;
    
    if  _comportamento not between 1 and 5 or
		_serieta not between 1 and 5 or
		_piacereViaggio not between 1 and 5 or
		_puntualita not between 1 and 5 or
		_sicurezza not between 1 and 5
	then
		signal sqlstate '45000'
			set message_text = 'Dati non validi';
	else
		insert into valutazione values(default,_votante,_votato,_data,_tipo, _comportamento,_serieta,
								   _piacereViaggio,_puntualita, _sicurezza,_recensione);
	end if;
END$$

delimiter ;