-- AFFIDABILITÀ UTENTE

-- Parte 1: ricerca affidabilità
select Affidabilita
from Utente
where CodFiscale='RSSVLN78E140715B'; -- cod fiscale di prova

-- Parte 2: aggiornamento ridondanza
drop event if exists AggiornaAffidabilita;
delimiter $$

create event AggiornaAffidabilita 
on schedule every 1 day
starts '2018-12-05 00:00:00' do
BEGIN
	declare mediavecchia double default 0;
    declare affidabilita_nuova double default 0;
    declare medianuova double default 0;
    declare scarto float default 0;
	drop table if exists UtentiDaAggiornare;
	create temporary table UtentiDaAggiornare
    (
     CF varchar(16) primary key
    );
    
    insert into UtentiDaAggiornare
    select Fruitore
    from carsharing
    where current_timestamp between TsFine and TsFine+interval 1 day;
    
    insert into UtentiDaAggiornare
    select distinct(A.Proprietario)
    from Autovettura A inner join Tracking T on A.Targa=T.Autovettura
    where current_timestamp between T.Timestamp and T.Timestamp + interval 1 day;
    
    begin
		declare finito tinyint default 0;
        declare _utenteattuale varchar(16); -- utente a cui si aggiorna l'affidabilità
        declare _comportamento tinyint; -- media dei punteggi ricevuti nelle valutazioni, sulla sezione comportamento
        declare _serieta tinyint;       -- di ogni parametro se ne andrà poi a fare la media
        declare _piacere tinyint;
        declare _puntualita tinyint;
        declare _sicurezza tinyint;
        declare UltimoSinistro timestamp default null;  -- Ultimo sinistro dell'Utente (serve a determinare i bonus/malus)
        declare _contovecchie integer default 0;        -- Numero di valutazioni ricevute nei giorni precedenti a quello appena passato
        declare _contonuove integer default 0;          -- Numero di valutazioni ricevute nell' ultimo giorno
        declare KmVecchi integer default 0;             -- Km percorsi nei giorni precedenti
        declare KmNuovi integer default 0;				-- Km percorsi nell'ultimo giorno
        declare _infrazionivel float default 0;         -- Infrazioni commesse nell'ultimo giorno
        
        declare UtentiVoti cursor for 
		select * from UtentiDaAggiornare;
        
        declare continue handler for not found
        set finito=1;
        
        open UtentiVoti;
        
        scan: loop
			
            fetch UtentiVoti into _utenteattuale;         -- Per ogni utente
            
            if finito=1 then
				leave scan;
            end if;
            
            select avg(Comportamento),avg(Serieta), avg(PiacereViaggio), avg(Puntualita), avg(SicurezzaGuida), count(*) into
					_comportamento, _serieta, _piacere, _puntualita, _sicurezza,_contovecchie
            from Valutazione
            where UtenteVotato=_utenteattuale and Data<current_date-interval 1 day;
            
            set mediavecchia=(_comportamento+_serieta+_piacere+_puntualita+_sicurezza)/5; -- media delle vecchie valutazioni
            
            set scarto=(                                         -- lo scarto rappresenta la somma algebrica di bonus/malus ottenuti in passato
				select Affidabilita                              -- questo valore andrà riaggiunto alla media aggiornata delle valutazioni, insieme con i nuovi bonus/malus
                from Utente
                where CodFiscale=_utenteattuale)-mediavecchia;
            
			if mediavecchia is null then set mediavecchia=0; end if;   -- non vogliamo che, se null, renda indeterminati gli altri parametri
            
            if scarto is null then set scarto=0; end if;
            
            select avg(Comportamento), avg(Serieta), avg(PiacereViaggio), avg(Puntualita), avg(SicurezzaGuida), count(*) -- parametri per il calcolo della media aggiornata
				into _comportamento, _serieta, _piacere, _puntualita, _sicurezza, _contonuove
			from Valutazione V inner join UtentiDaAggiornare UA on V.UtenteVotato=UA.CF
			where V.Data=current_date - interval 1 day and UtenteVotato=_utenteattuale;
            
            
            if (_contonuove<>0) then                          -- media ponderata (ogni media aritmetica moltiplica il numero di elementi su cui è stata calcolata)
					set medianuova=((mediavecchia*_contovecchie)+     -- il risultato è equivalente a quello che si otterrebbe con la media aritmetica di tutte le valutazioni, ma è molto meno costoso
						(_comportamento+_serieta+_piacere+_puntualita+_sicurezza)/5*_contonuove)/(_contovecchie+_contonuove);
            else
				set medianuova=mediavecchia;   -- se non ci sono nuove valutazioni
            end if;

            set affidabilita_nuova=medianuova;
            
            if(affidabilita_nuova=0) then
				set affidabilita_nuova=NULL;
            end if;    
            
            set affidabilita_nuova=medianuova+scarto; -- si riapplica lo scarto
            
            select max(S.timestamp) into UltimoSinistro
			from Sinistro S
            where Conducente=_utenteattuale and Ruolo<>'Non Colpevole';
            
            select ifnull(sum(T.lunghezza), 0) into KmVecchi    -- Km percorsi in eventi di Pool/Ride dall'ultimo sinistro, prima di ieri
            from Tratto T inner join Tracking TR using(CodStrada, KmStrada)
			where autovettura in 
				(select Targa 
                from Autovettura 
                where Proprietario=_utenteattuale)
            and TR.Timestamp<current_timestamp-interval 1 day and (TR.Timestamp>UltimoSinistro or UltimoSinistro is null)  
			and not exists 
				(select *
				 from carsharing CS
				 where autovettura in (
						select Targa 
						from Autovettura 
						where Proprietario=_utenteattuale)
				 and TR.Timestamp between Cs.TsInizio and CS.TsFine); 
            
            set KmVecchi=KmVecchi+(								-- Km percorsi in eventi di Car Sharing dall' ultimo sinistro prima di ieri
				select ifnull(sum(T.lunghezza), 0) 
				from carsharing CS inner join tracking TR on TR.autovettura = CS.autovettura
					inner join tratto T using(codStrada, kmstrada)
				where fruitore = _utenteattuale and 
					  TR.timestamp between CS.Tsinizio and CS.TsFine and 
                      (TR.Timestamp>UltimoSinistro or UltimoSinistro is null)
				and Cs.TsFine<current_timestamp - interval 1 day); 

            select ifnull(sum(T.lunghezza), 0) into KmNuovi    -- Km percorsi ieri in pool/ride
            from Tratto T inner join Tracking TR using(CodStrada, KmStrada)
			where TR.autovettura in 
				(select Targa 
                from Autovettura 
                where Proprietario=_utenteattuale)
            and TR.Timestamp>current_timestamp-interval 1 day and 
            (TR.Timestamp>UltimoSinistro or UltimoSinistro is null)   
			and not exists 
				(select *
				 from carsharing CS
				 where autovettura in (
						select Targa 
						from Autovettura 
						where Proprietario=_utenteattuale)
				 and TR.Timestamp between Cs.TsInizio and CS.TsFine);
            
            set KmNuovi=KmNuovi+(									-- Km ieri in car sharing
				select ifnull(sum(T.lunghezza), 0) 
				from carsharing CS inner join tracking TR on TR.autovettura = CS.autovettura
					inner join tratto T using(codStrada, kmstrada)
				where fruitore = _utenteattuale and 
					  TR.timestamp between CS.Tsinizio and CS.TsFine and
                      (TR.Timestamp>UltimoSinistro or UltimoSinistro is null) and
				       Cs.TsFine>=current_timestamp - interval 1 day);
            
			set affidabilita_nuova=affidabilita_nuova+0.1*((floor((KmNuovi+KmVecchi)/100))-floor(KmVecchi/100)); -- per spiegazione consulta documentazione
            
            set affidabilita_nuova=affidabilita_nuova-           -- penalità se ieri ha commesso sinistri
				(select ifnull(sum(D.Penalita),0) from
					(select if(S.Entita>=2, 1.25, 0.5) as Penalita
					 from Sinistro S
					 where S.Timestamp>=current_timestamp - interval 1 day and 
						   Conducente=_utenteattuale and Ruolo<>'Non colpevole'
				    ) as D);
            
            select ifnull(sum(D.Infrazione),0) into _infrazionivel   -- penalita per superamento limiti di velocita in eventi di pool/ride
            from(
				select case 
						when TR.VelocitaMedia-T.LimiteVelocita between 10 and 24 then 0.05
						when TR.VelocitaMedia-T.LimiteVelocita between 25 and 35 then 0.10
						when TR.VelocitaMedia-T.LimiteVelocita>35 then 0.50
						else 0 
					   end as Infrazione
				from Tratto T natural join tracking TR
				where TR.autovettura in 
					(select Targa 
					from Autovettura 
					where Proprietario=_utenteattuale)
				and TR.Timestamp>current_timestamp-interval 1 day   
				and not exists 
					(select *
					from carsharing CS
					where autovettura in (
							select Targa 
							from Autovettura 
							where Proprietario=_utenteattuale)
					and TR.Timestamp between Cs.TsInizio and CS.TsFine)
				)as D;    
            
            set affidabilita_nuova=affidabilita_nuova-_infrazionivel;
            
            select ifnull(sum(D.Infrazione),0) into _infrazionivel  -- penalità per infrazioni in eventi di car sharing
            from(
				select case 
							when TR.VelocitaMedia-T.LimiteVelocita between 10 and 24 then 0.05
							when TR.VelocitaMedia-T.LimiteVelocita between 25 and 35 then 0.10
							when TR.VelocitaMedia-T.LimiteVelocita>35 then 0.50
							else 0 
						end as Infrazione 
				from carsharing CS inner join tracking TR on TR.autovettura = CS.autovettura
					inner join tratto T using(codStrada, kmstrada)
				where fruitore = _utenteattuale and 
					TR.timestamp between CS.Tsinizio and CS.TsFine and
					Cs.TsFine<current_timestamp - interval 1 day
				 )as D;
            
			set affidabilita_nuova=affidabilita_nuova-_infrazionivel;
            
            if affidabilita_nuova>5 then     -- valori compresi tra 1 e 5
				set affidabilita_nuova=5;
            elseif affidabilita_nuova<1 then
				set affidabilita_nuova=1;
            end if;    
            
            update Utente             -- aggiorno il valore
            set Affidabilita=round(affidabilita_nuova,1)
            where CodFiscale=_utenteattuale;
            
		end loop;
        
        close UtentiVoti;
        
	end;		 
    
END$$

-- Parte 3: dense rank utenti
select CodFiscale, Nome, Cognome, 
	   if(Affidabilita=@affi, -- verifica se sono a pari merito
		  @rank=@rank,	      -- se si la posizione è la stessa
          @rank:=@rank+1+least(0, @affi:=Affidabilita)  -- altrimenti la posizione scala di 1 e la variabile si aggiorna sul nuovo valore         
         ) as Posizione                   
from Utente, (select @affi:=0)as D, (select @rank:=0)as N  -- inizializzazione variabili user-defined
order by Affidabilita desc