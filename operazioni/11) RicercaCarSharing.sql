-- RICERCA CAR-SHARING
drop procedure if exists ricercaCarSharing;
delimiter $$

create procedure ricercaCarSharing(in _comune varchar(20), in _giorno varchar(10), in _oraI time, in _oraF time)
BEGIN
	select A.targa, A.modello, A.livelloComfort,F.giorno,F.OraInizio,F.OraFine, F.EsigenzeParticolari,
		   F.costoKm,U.CodFiscale,U.telefono,U.Affidabilita
    from fruibilita F
		inner join autovettura A 
			on A.targa = F.autovettura
		inner join utente U 
			on A.proprietario = U.codFiscale
		inner join indirizzo I 
			using(cap,via,numeroCivico)
		where giorno = _giorno
        and _oraI >= oraInizio 
        and _oraF <= oraFine
        and I.comune = _comune
        and F.esigenzeParticolari = 'no';
END$$

delimiter ;

call ricercaCarSharing('Porcari','Giovedì','10:00:00','14:00:00');