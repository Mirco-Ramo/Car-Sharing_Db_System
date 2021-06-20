-- RICERCA POOL

drop procedure if exists ricercaPool;
delimiter $$

create procedure ricercaPool(in _giorno date, in _comuneP varchar(20), in  _comuneA varchar(20))
BEGIN

  	if _giorno < current_date() then
		signal sqlstate '45000'
		set message_text = 'Data non corretta';
	end if;

    select 
		P0.partenzaPrevista, P0.giornoArrivo,P0.flessibilita,P0.validita,
		P0.TariffaPercentualeVar,P0.tipPagamento,A.targa,A.modello,A.livelloComfort,
		U.codFiscale, U.nome,U.cognome,U.telefono,U.Affidabilita 
    from
    (
		select TP.pool,S.comune,TP.ordine
        from tragittoPool TP
			inner join strada S 
				on S.codStrada = TP.strada
            where TP.pool in -- Pool programmati nel giorno richiesto
			( 
				select idPool 
					from pool P 
					where day(P.partenzaPrevista) =  day(_giorno)
						and month(P.partenzaPrevista) =   month(_giorno)
						and year(P.partenzaPrevista) =  year(_giorno)
						and validita > 0
			)
            and S.comune =  _comuneP 
		) as D
	
    inner join
    
    (
		select TP.pool,S.comune,TP.ordine
			from tragittoPool TP
				inner join strada S 
					on S.codStrada = TP.strada
				where TP.pool in -- Pool programmati nel giorno richiesto
				( 
					select idPool 
						from pool P 
						where day(P.partenzaPrevista) =  day(_giorno)
							and month(P.partenzaPrevista) =   month(_giorno)
							and year(P.partenzaPrevista) =  year(_giorno)
							and validita > 0
				)
				and S.comune =  _comuneA
	) as D1
    on D.pool = D1.pool and D.ordine < D1.ordine
    inner join pool P0 on P0.idPool = D.pool
    inner join autovettura A on A.targa = P0.autovettura
    inner join utente U on U.codFiscale = A.proprietario;
       
END$$
delimiter ;

call ricercaPool('2018-12-07','Lucca','Pisa');
/*
insert into pool values('CP4','2018-12-07 09:00:00',null,0,48,'immediato', null,'EE547GV');
insert into pool values('CP5','2018-12-07 09:15:00',null,0,48,'immediato', null,'CS856AT');

insert into tragittoPool values('CP4','S15',1,1,1);
insert into tragittoPool values('CP4','S13',1,1,2);
insert into tragittoPool values('CP5','S15',1,1,1);
insert into tragittoPool values('CP5','S13',1,1,2);