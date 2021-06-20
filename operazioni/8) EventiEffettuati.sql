-- EVENTI PASSATI PRENOTATI DA UN UTENTE

drop procedure if exists mostraEventiPassati;
delimiter $$

create procedure mostraEventiPassati(in _cf varchar(16))
BEGIN
	declare error_codFiscale tinyint default null;

    select count(*) into error_codFiscale
		from utente 
        where CodFiscale = _cf 
        group by CodFiscale;
        
        if error_codFiscale is null then
			signal sqlstate '45000'
			set message_text = 'Codice fiscale non esistente';
		end if;
	-- Dati pool effetuati
	select PR.Pool, PR.Costo, PR.Accettato, PL.PartenzaPrevista, PL.GiornoArrivo, 
		   PL.Flessibilita, PL.validita, PL.TipPagamento,PL.TariffaPercentualeVar,
           A.targa, A.modello, A.LivelloComfort, U.CodFiscale, U.Nome,U.cognome,U.Affidabilita,
           U.telefono
		from prenotazione PR
			inner join pool PL
				on PR.pool = PL.idPool
			inner join autovettura A
				on A.targa = PL.autovettura
			inner join utente U
				on A.proprietario = U.codFiscale
        where partenzaPrevista < current_timestamp() 
			and PR.fruitore = _cf;
        
	-- Dati car effettuati
	select CS.IdSharing, CS.InizioProgrammato,CS.FineProgrammata,CS.TsInizio, CS.TsFine, CS.Carburante,CS.DanniGenerici,
		   CS.Costo, CS.Accettato, A.targa, A.modello, A.LivelloComfort, U.CodFiscale, U.Nome,U.cognome,U.Affidabilita,
           U.telefono
		from carsharing CS
			inner join autovettura A 
				on A.targa = CS.autovettura
			inner join utente U
				on U.codFiscale = A.proprietario
			where CS.inizioProgrammato < current_timestamp() 
				and CS.fruitore = _cf;
                
	-- Dati ride effettuati
    select C.IdChiamata,C.StradaAttuale,C.KmStradaAttuale,C.StradaDestinazione,C.KmStradaDestinazione,C.RideSharing,
		   RS.TsInizio, RS.TsFine, RS.CostoKm,A.Targa, A.Modello, A.LivelloComfort, U.CodFiscale, U.Nome,U.cognome,
           U.Affidabilita,U.telefono
		from chiamata C
			inner join ridesharing RS
				on C.ridesharing = RS.idRide
			inner join autovettura A 
				on A.targa = RS.autovettura
			inner join utente U 
				on A.proprietario = U.codFiscale
			where RS.tsInizio < current_timestamp() 
				and C.fruitore = _cf;

    
END$$
delimiter ;

-- prova della procedura
call mostraEventiPassati('NRELGU83C30G280V');
call mostraEventiPassati('ABCEFG00A00A000A');
