drop procedure if exists InserisciUtente;
delimiter $$

create procedure InserisciUtente (in _CodFiscale varchar(16), in _Nome varchar(100), in _Cognome varchar(100), 
								  in _Telefono varchar(15), in _CAP varchar(5), in _Via varchar(30),
                                  in _NumeroCivico varchar(5), in _Comune varchar(20), in _Provincia varchar(20),
                                  in _Localita varchar(20), in _TipologiaDocumento varchar(20), 
                                  in _NumDocumento varchar(15),in _Scadenza date, in _EnteDiRilascio varchar(25), 
                                  in _NomeUtente varchar(15), in _Password varchar(10), in _DomandaRiserva varchar(100),
                                  in _Risposta varchar(30))
BEGIN
	declare comuneRegistrato tinyint default 0;
    declare indirizzoRegistrato tinyint default 0;
    select count(*) into comuneRegistrato
    from Comuni
    where Comune=_Comune;
    
    if comuneRegistrato=0 then
		insert into Comuni values (_Comune,_Provincia);
    end if;
    
    select count(*) into indirizzoRegistrato
    from Indirizzo
    where Cap=_CAP and Via=_Via and NumeroCivico=_NumeroCivico;
    
    if indirizzoRegistrato=0 then
		insert into Indirizzo values (_CAP, _Via, _NumeroCivico, _Comune, _Localita);
    end if;
    
    insert into Utente 
    values(_CodFiscale, _Nome, _Cognome, _Telefono, _Cap, _Via, _NumeroCivico, current_date(), default);
    
    insert into Account
    values(_NomeUtente, _Password, _DomandaRiserva, _Risposta, default, _CodFiscale);
    
    insert into Documento
    values(_TipologiaDocumento, _NumDocumento, _Scadenza, _EnteDiRilascio, default, _CodFiscale);
    
    select 'Utente registrato, si prega di confermare il documento prima di poter accedere ai servizi' as Messaggio;
    
END$$    

call InserisciUtente('BBB','BB', 'AAA', '00000', '00000','Via AAA', '00', 'BBB', 'BBB', 'BBB', 'BBB', '234', '2018-12-25', 'IO', 'BBB', 'AAA', 'AAA', 'BBB');                               