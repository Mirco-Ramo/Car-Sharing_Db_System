-- SCELTA MIGLIOR PROPONENTE RIDE-SHARING

drop procedure if exists ricercaRide;
delimiter $$

create procedure ricercaRide(in _chiamata varchar(10))

BEGIN
    declare stradaF varchar(10); -- Strada Fruitore
    declare comuneF varchar(20); -- Comune Fruitore
    declare auto varchar(7); -- Autovettura Considerata 
	declare stradaP varchar(10); -- Strada Proponente
	declare comuneP varchar(20); -- Comune Proponente
    declare finito tinyint default 0;
    declare id varchar(10); -- idSharing
    declare comfort float; -- livello comfort
    declare affidabilita float; -- affidabilita di un utente
    
    declare listaAuto cursor for-- Targa delle autovetture attualmente disponibili per rideSharing
		select idRide, autovettura
			from rideSharing RS
			where tsInizio is null and tsFine is null;
    
    declare continue handler for not found 
		set finito = 1;
        
	select StradaAttuale -- Dettagli sulla posizione partenza attuale
	into stradaF
		from chiamata 
		where idChiamata = _chiamata;
        
	select comune into comuneF -- Comune della posizione di partenza
		from strada 
		where codStrada = stradaF;
	
    drop table if exists punteggio;
	create temporary table punteggio
    (
		idSharing varchar(10),
		punti tinyint,
        affidabilita float,
        livelloComfort float
	);
        
	open listaAuto;
    
    scan:loop -- Per ogni autovettura disponibile si controlla strada e comune in cui si trova
    
		fetch listaAuto into id,auto;
        
        if finito = 1 then
			leave scan;
		end if;
        
        select codStrada into stradaP-- Ricavo la strada in cui si trova il proponente 
			from tracking TR
			where autovettura = auto 
            and TR.timestamp = 
            (
				select max(TR1.timestamp) 
					from tracking TR1 
					where autovettura = auto
			);
			
		select comune into comuneP -- Ricavo comune in cui si trova il proponente
			from strada	
            where codStrada=stradaP; 
            
            
        select livelloComfort into comfort -- Ricavo il livello comfort dell'autovettura
			from autovettura A
            where A.targa = auto; 
            
		select U.affidabilita into affidabilita -- Ricavo il valore di affidabilità del proponente
			from utente U 
				inner join autovettura A 
					on A.proprietario=U.codFiscale
			where A.targa = auto;
           
		case -- Assegna punteggio in base al comune e strada e crea record
			when comuneP = comuneF and ComuneP is not null and  stradaP = stradaF and stradaP is not null then
				insert into punteggio values(id,15,ifnull(affidabilita,1),comfort);            
			when comuneP = comuneF and stradaP <> stradaF then
				insert into punteggio values(id,10,ifnull(affidabilita,1),comfort);
			when stradaP = stradaF and comuneP <> comuneF then
				insert into punteggio values(id,5,ifnull(affidabilita,1),comfort);
			when stradaP <> stradaF and comuneP <> comuneF then
				insert into punteggio values(id,0,ifnull(affidabilita,1),comfort);
			else begin end;
		end case;   
        
    end loop;
    
    close listaAuto;
	
    select U.codFiscale, U.nome,U.cognome,U.Affidabilita, 
		   U.telefono, A.targa, A.modello, A.livelloComfort, RS.costoKm
		from punteggio P
			inner join rideSharing RS
				on RS.idRide = P.idSharing
			inner join autovettura A
				on RS.autovettura = A.targa
			inner join utente U
				on U.codFiscale = A.proprietario
        order by P.punti,P.affidabilita,P.livelloComfort desc;

END$$
delimiter ;

call RicercaRide('C7');
/*
insert into chiamata values('C7','S15',1,'S5',1,default,current_timestamp(),null,'DNILNZ79C19D180Q',null);
insert into ridesharing values('RS5',null,null,5,'FA547RF');
insert into ridesharing values('RS6',null,null,5,'EW748DC');
select * from strada;
insert into tracking values('EW748DC','S15',1,current_timestamp(),60);
insert into tracking values('FA547RF','S15',1,current_timestamp(),60);

update autovettura set livelloComfort = 2 where targa ='FA547RF' ;