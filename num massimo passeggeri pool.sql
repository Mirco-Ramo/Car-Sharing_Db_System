drop trigger if exists ContaPasseggeri;
delimiter $$

create trigger ContaPasseggeri 
before insert on Prenotazione
for each row
BEGIN
	declare passeggeri_attuali tinyint;
    declare passeggeri_max tinyint;
    
    select count(*) into passeggeri_attuali
    from Prenotazione P
    where P.Pool=new.Pool and P.Accettato='si' and P.Cancellata='no';
    
    select M.NumPosti into passeggeri_max
    from modelliauto M inner join Autovettura A on M.Modello=A.Modello
    where A.Targa=
		(select PO.Autovettura
         from Pool PO
         where PO.IDPool=new.Pool);
    
    if ((passeggeri_attuali+1)>passeggeri_max) then
		signal sqlstate '45000'
        set message_text='Questo pool è già al completo';
    end if;    
    
END$$