-- AGGIORNA TRATTO
update tratto 
	set numeroCareggiate = 'nuovo_numero',numeroCorsie='nuovo_numero',sensiMarcia='1/2',
		limiteVelocita='nuova_velocita',costo='nuovo_costo',chiuso='si/no',lunghezza='nuova_lunghezza'
	where codStrada = 'codStrada_considerata' and kmStrada = 'kmStrada_considerato';
    
-- AGGIORNA STRADA
update strada
	set IdNumerico='nuovo_id', TipologiaAmm='nuova_tipologia', Categorizzazione='nuova_categorizzazione', 
		Nome='nuovo_nome', Comune='nuovo_comune',ClassificazioneTecnica='nuova_classificazione',
        SecondoId='nuovo_secondoId'
	where CodStrada = 'codStrada_considerata';
    
update tratto 
	set numeroCareggiate = 'nuovo_numero',numeroCorsie='nuovo_numero',sensiMarcia='1/2',
		limiteVelocita='nuova_velocita',costo='nuovo_costo',chiuso='si/no',lunghezza='nuova_lunghezza'
	where codStrada = 'codStrada_considerata' and kmStrada = 'kmStrada_considerato';
    
-- CREAZIONE VARIAZIONE
insert into variazione values('codVariazione','tipologia','numero_km_parte_modificata');
insert into tragittoTarget values('codVariazione','codStrada','kmInizio','kmFine','ordine');-- Per ogni strada del tragitto*
    
-- TRACCIAMENTO AUTOVETTURA
insert into tracking values('targa_autovetura','cod_strada_attuale','km_strada_attuale','timestamp_attuale',
							'velocita_media_attuale');


-- INSERIMENTO CHIAMATA
insert into chiamata values('cod_chiamta','cod_strada_attuale','km_strada_attuale',
							'cod_strada_destinazione','km_strada_destinazione','stato=pending',
                            'Ts_chiamata','Ts_risposta','cod_fiscale_fruitore','null');

-- PRENOTAZIONE POOL
insert into prenotazione values('timestamp_attuale','idPool','cod_fiscale_fruitore','cod_variazione','null',
								'kmVariazione*tariffaPercentualeVar + costo base','null');

-- NOLEGGIO AUTOVETTURA
insert into carSharing values('idSharing','null','null','data_orario_scelti','data_orario_scelti','null',
							  'null','null','costo_orario * tempo_noleggio','targa_autovettura_nolegiata',
							  'cod_fiscale_fruitore');

-- ATTIVAZIONE RIDE SHARING
insert into rideSharing values('idRide','null','null','costoKm','targa_autovettura_in_uso');
insert into tragittoride values('idRide','cod_strada',
								'kmInzio','kmFine','ordine'); -- Per ogni strada del traggito*

-- CREAZIONE POOL
insert into pool values('idPool','data_orario_partenza','giorno_arrivo','grado_flessibilità','ore_validità',
						'tipo_pagamento','tariffa_percentuale_var');
insert into tragittoPool values('idPool','codStrada','kmInizio','kmFine','ordine');-- Per ogni strada del tragitto*

-- MODIFICA FRUIBILITÀ
update fruibilita 
	set oraInizio = 'nuova_ora_inizio', oraFine = 'nuova_ora_fine',
		esigenzeParticolari = 'nuova_esigenza_particolare', costoKm='nuovo_costoKm'
	where targa='targa_auto_considerata' and giorno='giorno_considerato';


-- REGISTRAZIONE AUTOVETTURA
insert into autovettura values('targa_auto','tipo_alimentazione','modello','costo_operativo','costo_usura'
							   'carburante_presente','kmPercorsi','danniGenerici','null','cod_fiscale_proprietario');
insert into equipaggiamento values('targa_auto','codice_optional'); -- Da cui si calcola in automatico livelloComfort

insert into alimentazioneAuto values('modello','tipo_alimentazione','velocita_max','consumo_urbano'
									 'consumo_extra_urbano','consumo_misto','capacita_serbatoio');
                                     
insert into modelliAuto values('modello','casa_produttrice','cilindrata','numPosti');						
