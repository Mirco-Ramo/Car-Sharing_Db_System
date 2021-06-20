create table if not exists CriticitaTraffico
(
 CodStrada varchar(10),
 KmStrada smallint,
 TempoMedioPercorrenza float,
 TempoAttualePercorrenza float,
 AumentoPercentuale tinyint,
 UltimoAggiornamento timestamp,
 primary key(CodStrada, KmStrada)
);

-- Rilevazione on demand dei tratti
-- Qualsiasi utente può richiedere la valutazione del livello di traffico in un preciso tratto e istante
-- I tratti più trafficati saranno inseriti nella materialised view CriticitaTraffico, 
-- la quale mantiene i dati finché sono considerati attendibili(15min)
drop function if exists TempoIstantaneo;
delimiter $$

create function TempoIstantaneo( _CodStrada varchar(10), _KmStrada smallint)
returns float not deterministic
BEGIN
	declare AutoPassate smallint;
    declare TempoMedio float;
    declare Lung float;
    declare TempoIstantaneoPercorrenza_ float default 0;
    declare Percentuale tinyint;
    declare GiaPresente tinyint default 0;
    
	
    select count(distinct Autovettura) into AutoPassate
    from Tracking T
    where CodStrada=_CodStrada and 
		  KmStrada=_KmStrada and 
          timestamp>=current_timestamp-interval 15 minute;
    
    select TempoMedioPercorrenza, Lunghezza into TempoMedio, Lung
    from Tratto
    where CodStrada=_CodStrada and KmStrada=_KmStrada;
    
    case 
    when AutoPassate>=3 then 
		select Lung/(avg(VelocitaMedia))*60 into TempoIstantaneoPercorrenza_
         from Tracking T
		 where CodStrada=_CodStrada and 
			   KmStrada=_KmStrada and 
               timestamp>=current_timestamp-interval 15 minute;
    when AutoPassate=2 then 
		select Lung*60/(2*(avg(VelocitaMedia))+TempoMedio)/3 into TempoIstantaneoPercorrenza_
         from Tracking T
		 where CodStrada=_CodStrada and 
			   KmStrada=_KmStrada and 
               timestamp>=current_timestamp-interval 15 minute;
    when AutoPassate=1 then
		select Lung*60/(avg(VelocitaMedia)+2*TempoMedio)/3 into TempoIstantaneoPercorrenza_
         from Tracking T
		 where CodStrada=_CodStrada and 
			   KmStrada=_KmStrada and 
               timestamp>=current_timestamp-interval 15 minute;
    else set TempoIstantaneoPercorrenza_ =TempoMedio;
    end case;
    
    set Percentuale=((TempoIstantaneoPercorrenza_/TempoMedio)-1)*100; 
    
    select count(*) into GiaPresente
    from CriticitaTraffico
    where CodStrada=_CodStrada and KmStrada=_KmStrada;
    
    if GiaPresente=0 then
		insert into CriticitaTraffico
        values(_CodStrada, _KmStrada, TempoMedio, TempoIstantaneoPercorrenza_,Percentuale, current_timestamp);
    else
		update CriticitaTraffico
        set UltimoAggiornamento=current_timestamp, 
            TempoMedioPercorrenza=Tempomedio,
            TempoAttualePercorrenza= TempoIstantaneoPercorrenza_,
            AumentoPercentuale=Percentuale;
    end if;  
    
    return TempoIstantaneoPercorrenza_;
    
END$$
delimiter ; 

drop event if exists EliminaNonAttendibili;
delimiter $$

create event EliminaNonAttendibili
on schedule every 15 minute
starts '2018-12-06 03:00:00' do
BEGIN
	delete from CriticitaTraffico
    where UltimoAggiornamento<current_timestamp - interval 15 minute;
END$$
delimiter ;
select TempoIstantaneo('S1',5);
select * from CriticitaTraffico