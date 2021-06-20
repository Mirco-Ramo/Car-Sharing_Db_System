-- ELIMINAZIONE DI UN UTENTE

drop trigger if exists eliminaUtente;
delimiter $$
create trigger eliminaUtente 
	before delete on utente
	for each row
BEGIN
	declare _targa varchar(7);
	declare finito integer default 0;
    
    declare listaTarga cursor for
		select targa -- Un utente potrebbe possedere più autovetture
			from autovettura 
			where proprietario = old.codFiscale;
            
	declare continue handler for not found
		set finito = 1;
        
	delete  -- Elimino documento
		from documento
		where utente = old.CodFiscale;
        
	delete  -- Elimino account
		from account 
		where utente = old.CodFiscale;
        
	delete -- Elimino valutazioni ricevute
		from valutazione
		where utenteVotato = old.CodFiscale;
        
	open listaTarga;
    
	scan: loop -- Per ogni auto posseduta
		fetch listaTarga into _targa;
        
        if finito = 1 then
			leave scan;
		end if;
        
        delete  -- Elimino tutti gli orari di fruibilità
			from fruibilita 
			where autovettura = _targa;
            
		delete -- Elimino tutti gli optional
			from equipaggiamento 
			where autovettura = _targa;
        
        update autovettura
			set proprietario = null -- L'autovettura non può essere eliminata (compromette dati sinistri e tracking)
			where targa = _targa; -- Per rispettare le integrità referenziali, Proprietario viene posto uguale a NULL
        
    end loop;
    
    close listaTarga;
    
END$$
delimiter ;

delete from utente 
	where codFiscale = 'RSSVLN78E140715B';
