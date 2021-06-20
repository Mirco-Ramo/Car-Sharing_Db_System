-- EVENTI FUTURI PRENOTATI DA UN UTENTE

drop procedure if exists mostraEventiFuturi;
delimiter $$

create procedure mostraEventiFuturi(in _cf varchar(16))
BEGIN
	declare error_codFiscale tinyint default null;
    
    select count(*) into error_codFiscale
		from utente 
        where CodFiscale = _cf;
        
        if error_codFiscale=0 then
			signal sqlstate '45000'
			set message_text = 'Codice fiscale non esistente';
		end if;
    

	-- Dati pool prenotati
	select PR.Pool, PR.Costo, PR.Accettato, 
		   PL.PartenzaPrevista, PL.GiornoArrivo, PL.Flessibilita, PL.validita, PL.TipPagamento,PL.TariffaPercentualeVar,
           A.Targa, A.Modello, A.LivelloComfort, 
           U.CodFiscale, U.Nome,U.cognome,U.Affidabilita, U.Telefono
		from prenotazione PR
			inner join pool PL
				on PR.pool = PL.idPool
			inner join autovettura A
				on A.targa = PL.autovettura
			inner join utente U
				on A.proprietario = U.codFiscale
        where partenzaPrevista > current_timestamp() 
			and PR.fruitore = _cf;
        
	-- Dati car prenotati
	select CS.IdSharing, CS.InizioProgrammato, CS.FineProgrammata, CS.Costo, CS.Accettato, A.targa,
		   A.modello, A.LivelloComfort, U.CodFiscale, U.Nome,U.cognome,U.Affidabilita,
           U.telefono
		from carsharing CS
			inner join autovettura A 
				on A.targa = CS.autovettura
			inner join utente U
				on U.codFiscale = A.proprietario
			where CS.inizioProgrammato > current_timestamp() 
				and CS.fruitore = _cf;

END$$
delimiter ;

call mostraEventiFuturi('CRLNTN92E15F130C');
call mostraEventiFuturi('ABCEFG00A00A000A');
