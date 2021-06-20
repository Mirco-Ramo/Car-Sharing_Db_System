drop trigger if exists ControllaTrattiChiusiPool;
delimiter $$

create trigger ControllaTrattiChiusiPool
before insert on TragittoPool
for each row
BEGIN
	declare chiusi integer default 0;
	if new.KmInizio<new.KmFine then
		select count(*) into chiusi
        from Tratto
        where CodStrada=new.Strada and
              KmStrada>=new.KmInizio and
              KmStrada<=new.KmFine and
              T.Chiuso='si';
    elseif new.KmInizio=new.KmFine then
		select if(T.Chiuso='si', 1, 0) into chiusi
        from Tratto T
        where T.CodStrada=new.Strada and T.KmStrada=new.KmInizio;
    else
		select count(*) into chiusi
        from Tratto
        where CodStrada=new.Strada and
              KmStrada<=new.KmInizio and
              KmStrada>=new.KmFine and
              T.Chiuso='si';
    end if;
    
    if chiusi>0 then
		signal sqlstate '45000'
        set message_text='Il tragitto prevede il passaggio su un tratto chiuso';
    end if;    
    
END$$

drop trigger if exists ControllaTrattiChiusiRide;
delimiter $$

create trigger ControllaTrattiChiusiRide
before insert on TragittoRide
for each row
BEGIN
	declare chiusi integer default 0;
	if new.KmInizio<new.KmFine then
		select count(*) into chiusi
        from Tratto
        where CodStrada=new.Strada and
              KmStrada>=new.KmInizio and
              KmStrada<=new.KmFine and
              T.Chiuso='si';
    elseif new.KmInizio=new.KmFine then
		select if(T.Chiuso='si', 1, 0) into chiusi
        from Tratto T
        where T.CodStrada=new.Strada and T.KmStrada=new.KmInizio;
    else
		select count(*) into chiusi
        from Tratto
        where CodStrada=new.Strada and
              KmStrada<=new.KmInizio and
              KmStrada>=new.KmFine and
              T.Chiuso='si';
    end if;
    
    if chiusi>0 then
		signal sqlstate '45000'
        set message_text='Il tragitto prevede il passaggio su un tratto chiuso';
    end if;    
    
END$$
