-- VERIFICA STATO AUTOVETTURA 

drop procedure if exists riconsegnaAuto;
delimiter $$

create procedure riconsegnaAuto(in _idSharing varchar(10), in _carburanteF float, in _danniGenericiF text)
BEGIN
	declare carburanteI float;
    declare danniGenericiI text;
    declare varTarga varchar(7);
 
    select CS.autovettura into varTarga -- Ricavo la targa del CarSharing
		from carSharing CS
        where CS.idSharing = _idSharing;
    
    select A.carburante, A.danniGenerici into carburanteI,danniGenericiI -- Ricavo i valori dello stato iniziale
		from autovettura A
		where A.targa = varTarga;
	       
    if  _carburanteF >= (carburanteI - 0.5) and  -- Controllo dei due stati
	(	_danniGenericiF = danniGenericiI or 
		(_danniGenericiF is null and danniGenericiI is null)
	) then
      
		update carsharing CS
			set CS.tsFine = current_timestamp(),
				CS.carburante = _carburanteF, 
				CS.danniGenerici = _danniGenericiF
			where CS.idSharing = _idSharing;
	else
		signal sqlstate '45000'
		set message_text = 'Stato finale differente dallo stato iniziale';
    end if;
    
END$$

delimiter ;
