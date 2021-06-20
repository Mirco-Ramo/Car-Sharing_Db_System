drop table if exists Coinvolgimento;
drop table if exists Sinistro;
drop table if exists AutoCoinvolta;

drop table if exists TragittoRide;
drop table if exists TragittoTarget;
drop table if exists TragittoPool;

drop table if exists Chiamata;
drop table if exists RideSharing;

drop table if exists Tracking; 
drop table if exists Incrocio;
drop table if exists Tratto;
drop table if exists Strada;

drop table if exists Prenotazione;
drop table if exists Variazione;
drop table if exists Pool;
drop table if exists CarSharing;

drop table if exists Equipaggiamento;
drop table if exists Optional;
drop table if exists Fruibilita;
Drop table if exists Autovettura;
drop table if exists ModelliAuto;
Drop table if exists AlimentazioneAuto;
Drop table if exists Valutazione;
Drop table if exists Account;
Drop table if exists Documento;
drop table if exists Utente;
Drop table if exists Indirizzo;
Drop table if exists Comuni;

create table Comuni
(
 Comune varchar(20) Primary key,
 Provincia varchar(20) not null
);

create table Indirizzo
(
 Cap varchar(5) not null,
 Via varchar(30) not null,
 NumeroCivico varchar(5) not null,
 Comune varchar(20) not null,
 Localita varchar (20),
 Primary Key (Cap,Via,NumeroCivico),
 Foreign Key (Comune) references Comuni(Comune)
);

create table Utente
(
 CodFiscale varchar(16) primary key,
 Nome varchar(100) not null,
 Cognome varchar(100) not null,
 Telefono varchar(15),
 Cap varchar(5) not null,
 Via varchar(30) not null,
 NumeroCivico varchar(5) not null,
 DataIscrizione date not null,
 Affidabilita float default null,
 Foreign Key(Cap,Via,NumeroCivico) references Indirizzo (Cap,Via,NumeroCivico)
); 

create table Account
(
 NomeUtente varchar(15) primary key,
 Password varchar(10) not null,
 DomandaRiserva varchar(100),
 Risposta varchar(30),
 Stato varchar(15) default 'Inattivo' not null,
 Utente varchar(16),
 foreign key (Utente) references Utente(CodFiscale)
);

create table Documento
(
 Tipologia varchar(20),
 NumDocumento varchar(15),
 Scadenza date not null,
 EnteRilascio varchar(25) not null,
 Verificato varchar(2) default 'no' not null,
 Utente varchar(16),
 Primary key(Tipologia,NumDocumento),
 Foreign key(Utente) references Utente(CodFiscale)
);

create table Valutazione
(
 CodValutazione integer primary key auto_increment,
 UtenteVotante varchar(16),
 UtenteVotato varchar(16),
 Data date not null,
 tipoEvento varchar(4),
 Comportamento tinyint not null,
 Serieta tinyint not null,
 PiacereViaggio tinyint not null,
 Puntualita tinyint not null,
 SicurezzaGuida tinyint not null,
 Recensione text,
 Foreign Key (UtenteVotato) references Utente(CodFiscale),
 Foreign Key (UtenteVotante) references Utente(CodFiscale)
);

create table ModelliAuto
(
 Modello varchar(20) primary key,
 CasaProduttrice varchar(25) not null,
 Cilindrata varchar(10),
 NumPosti tinyint not null
);

create table AlimentazioneAuto
(
 Modello varchar(20) not null,
 TipAlimentazione varchar(10) not null,
 VelocitaMax smallint,
 ConsumoUrbano float,
 ConsumoExtraUrbano float,
 ConsumoMisto float,
 CapacitaSerbatoio tinyint,
 primary Key (Modello,TipAlimentazione)
);

create table Autovettura
(
 Targa varchar(7) primary key,
 TipAlimentazione varchar(10) not null,
 Modello varchar(20) not null,
 AnnoImmatricolazione year,
 CostoOperativo float not null,
 CostoUsura float not null,
 Carburante float not null,
 KmPercorsi integer not null,
 DanniGenerici text,
 LivelloComfort float not null default 1,
 Proprietario varchar(16),
 Foreign key (Proprietario) references Utente(CodFiscale),
 Foreign key (Modello) references ModelliAuto(Modello) on delete cascade,
 Foreign Key (Modello, TipAlimentazione) references AlimentazioneAuto(Modello, TipAlimentazione) on delete cascade
)engine=InnoDB;

create table Fruibilita
(
 Giorno varchar(10),
 OraInizio time,
 OraFine time not null,
 Costokm tinyint not null,
 EsigenzeParticolari varchar(2) not null default 'no',
 Autovettura varchar(7),
 primary key(Giorno, OraInizio, Autovettura),
 foreign key(Autovettura) references Autovettura(Targa)
); 

create table Optional
(
 CodOptional integer auto_increment primary key,
 PesoComfort float not null,
 NomeOptional varchar(50) not null
); 

create table Equipaggiamento
(
 Autovettura varchar(7),
 Optional integer,
 primary key (Autovettura, Optional),
 foreign key (Autovettura) references autovettura (Targa),
 foreign key (Optional) references Optional (CodOptional)
); 

create table CarSharing
(
 IdSharing varchar(10) primary key,
 TsInizio timestamp null default null, -- Altrimenti metterebbe current_timestamp
 TsFine timestamp null default null,
 InizioProgrammato timestamp not null,
 FineProgrammata timestamp not null,
 Carburante float,
 DanniGenerici text,
 Accettato varchar(2) not null default 'no',
 Costo float,
 Autovettura varchar(7),
 Fruitore varchar(16) not null,
 Foreign key (autovettura) references Autovettura(Targa)
); 

create table Pool
(
 IdPool varchar(10) primary key,
 PartenzaPrevista timestamp not null,
 GiornoArrivo date,
 Flessibilita tinyint not null default 0,
 Validita float not null,
 TipPagamento varchar(100),
 TariffaPercentualeVar tinyint,
 Autovettura varchar(7),
 foreign key (autovettura) references Autovettura(Targa)
);

create table Variazione 
(
 CodVariazione varchar (7) primary key,
 Tipologia varchar(50),
 Entita tinyint not null
);

create table Prenotazione
(
 Timestamp timestamp,
 Pool varchar(10),
 Fruitore varchar(16),
 Variazione varchar(7),
 Accettato varchar(2) default 'no',
 Costo float not null,
 Cancellata varchar(2) default 'no',
 primary key(Pool, Fruitore, Timestamp),
 foreign key(Variazione) references Variazione(CodVariazione),
 foreign key(Fruitore) references Utente(CodFiscale),
 foreign key(Pool) references Pool(IdPool)
);

create table Strada 
(
 CodStrada varchar(10) primary key,
 TipologiaAmm varchar(3),
 IdNumerico smallint,
 Categorizzazione varchar(5),
 Nome varchar(25),
 Comune varchar(20),
 ClassificazioneTecnica varchar(25) not null,
 SecondoId varchar(7),
 foreign key (Comune) references Comuni(Comune)
);

create table Tratto 
(
 CodStrada varchar(10),
 KmStrada smallint,
 Latitudine varchar(16) not null,
 Longitudine varchar(16) not null,
 NumeroCarreggiate tinyint,
 NumeroCorsie tinyint,
 SensiMarcia tinyint,
 LimiteVelocita smallint not null,
 Costo float,
 TempoMedioPercorrenza float not null,
 Chiuso varchar(2) default 'no',
 Lunghezza float,
 primary key(CodStrada, KmStrada),
 foreign key (CodStrada) references Strada(CodStrada)
);

create table Incrocio
(
 CodStrada varchar(10),
 KmStrada smallint,
 CodStradaIncrociata varchar(10),
 KmStradaIncrociata smallint,
 Tipo varchar(15),
 Latitudine varchar(16),
 Longitudine varchar(16),
 Primary key (CodStrada, KmStrada, CodStradaIncrociata, KmStradaIncrociata),
 foreign key (CodStrada, KmStrada) references Tratto (CodStrada, KmStrada),
 foreign key (CodStradaIncrociata, KmStradaIncrociata) references Tratto (CodStrada, KmStrada)
);

create table Tracking 
(
 Autovettura varchar(7),
 CodStrada varchar(10),
 KmStrada smallint,
 Timestamp timestamp,
 VelocitaMedia float, -- Può essere null per determinare l'arrivo
 primary key(Autovettura, CodStrada, KmStrada, Timestamp),
 foreign key (Autovettura) references Autovettura(Targa),
 foreign key (CodStrada, KmStrada) references Tratto(CodStrada, KmStrada)
);

create table RideSharing 
(
 IdRide varchar(10) primary key,
 TsInizio timestamp  null default null,
 TsFine timestamp  null default null,
 CostoKm float not null,
 Autovettura varchar(7),
 foreign key(Autovettura) references autovettura(Targa)
);

create table Chiamata
(
 IdChiamata varchar(10) primary key,
 StradaAttuale varchar(10) not null,
 KmStradaAttuale smallint,
 StradaDestinazione varchar(10),
 KmStradaDestinazione smallint,
 Stato varchar(10) default 'pending',
 TsChiamata timestamp not null,
 TsRisposta timestamp null default null,
 Fruitore varchar(16),
 RideSharing varchar(10),
 foreign key (StradaAttuale, KmStradaAttuale) references Tratto(Codstrada, KmStrada),
 foreign key (StradaDestinazione, KmStradaDestinazione) references Tratto(CodStrada, KmStrada),
 foreign key (Fruitore) references Utente(CodFiscale),
 foreign key (RideSharing) references RideSharing(IdRide)
); 

create table TragittoPool
(
 Pool varchar(10),
 Strada varchar(10),
 KmInizio smallint not null,
 KmFine smallint not null,
 Ordine smallint not null,
 primary key(Pool,Strada),
 foreign key(Pool) references Pool(IdPool),
 foreign key(Strada) references Strada(CodStrada)
); 
 
create table TragittoTarget
(
 Variazione varchar(7),
 Strada varchar(10),
 KmInizio smallint not null,
 KmFine smallint not null,
 Ordine smallint not null,
 primary key(Variazione,strada),
 foreign key(Variazione) references Variazione(CodVariazione),
 foreign key(Strada) references Strada(CodStrada)
); 

create table TragittoRide
(
 RideSharing varchar(10),
 Strada varchar(10),
 KmInizio smallint not null,
 KmFine smallint not null,
 Ordine smallint not null,
 primary key(RideSharing,Strada),
 foreign key(RideSharing) references RideSharing(IdRide),
 foreign key(Strada) references Strada(CodStrada)
);  

create table AutoCoinvolta
(
 TargaCoinvolta varchar(7) primary key,
 Modello varchar(20),
 foreign key(Modello) references modelliAuto(Modello)
);

create table Sinistro
(
 CodSinistro varchar(8) primary key,
 Timestamp timestamp not null,
 Dinamica text,
 Risolto varchar(2) not null default 'no',
 Entita tinyint not null,
 Ruolo varchar(10),
 Conducente varchar(16),
 Autovettura varchar(7),
 foreign key(Conducente) references Utente(CodFiscale),
 foreign key(Autovettura) references Autovettura(Targa)
); 

create table coinvolgimento 
(
 sinistro varchar(8),
 autovetturaCoinvolta varchar(7),
 primary key(sinistro,autovetturaCoinvolta),
 foreign key(sinistro) references sinistro(codSinistro),
 foreign key(autovetturaCoinvolta) references autoCoinvolta(targaCoinvolta)
 );
