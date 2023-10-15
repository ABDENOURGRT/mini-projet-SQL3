

			/**********  qstn2  **********/

create tablespace SQL3_TBS datafile 'F:\Etudes\M1\S2\BDA\projet sql3\SQL3_TBS.dat' size 50M autoextend on online;
create temporary tablespace SQL3_TempTBS tempfile 'F:\Etudes\M1\S2\BDA\projet sql3\SQL3_TempTBS.dat' size 50M autoextend on;

			/**********  qstn3  **********/

create user SQL3 identified by mdp default tablespace SQL3_TBS temporary tablespace SQL3_TempTBS;

			/**********  qstn4  **********/

grant all privilege to SQL3;

			/**********  qstn5  **********/

connect SQL3/mdp;
create type tsport;
/
create type tsportifs;
/
create type tseances;
/
create type tarbitrer;
/
create type tjouer;
/
create type tville;
/
create type tgymnases;
/
create type tentrainer;
/
create type t_set_gymnases as table of ref tgymnases;
/
create type t_set_entrainer as table of ref tentrainer;
/
create type t_set_sportifs as table of ref tsportifs;
/
create type t_set_conseiller as table of ref tsportifs;
/
create type t_set_seances as table of ref tseances;
/
create type t_set_arbitrer as table of ref tarbitrer;
/
create type t_set_jouer as table of ref tjouer;
/
create or replace type tville as object (ville varchar2(50), liste_gymnases t_set_gymnases);
/
create or replace type tgymnases as object (idgymnase integer , nomgymnase varchar2(50), adresse varchar2(50), ville ref tville, surface number, liste_seances t_set_seances);
/
create or replace type tsport as object (idsport integer, libelle varchar2(50), liste_entrainer t_set_entrainer, liste_arbitrer t_set_arbitrer, liste_jouer t_set_jouer, liste_seances t_set_seances);
/
create or replace type tsportifs as object (idsportif integer, nom varchar2(20), prenom varchar2(20), sexe varchar2(2), age integer, idsportifconseiller ref tsportifs, liste_entrainer t_set_entrainer, liste_arbitrer t_set_arbitrer, liste_jouer t_set_jouer, liste_conseiller t_set_conseiller);
/
create or replace type tentrainer as object (idsportif ref tsportifs, idsport ref tsport, liste_seances t_set_seances);
/
create or replace type tarbitrer as object (idsportif ref tsportifs, idsport ref tsport);
/
create or replace type tjouer as object (idsportif ref tsportifs, idsport ref tsport);
/
create or replace type tseances as object (idgymnase ref tgymnases, idsport ref tsport, entrainer ref tentrainer, jour varchar2(10), horaire number, duree integer);
/

			/**********  qstn6  **********/

create table ville of tville(
    constraint pk_ville primary key(ville))
    nested table liste_gymnases store as table_ville_gymnases;
create table gymnases of tgymnases(
    constraint pk_gymnases primary key(idgymnase),
    constraint fk_gymnases foreign key(ville) references ville on delete cascade)
    nested table liste_seances store as table_gymnases_seances;
create table sportifs of tsportifs(
    constraint pk_sportifs primary key(idsportif),
    constraint fk_conseiller foreign key(idsportifconseiller) references sportifs on delete cascade,
    constraint ck_sexe check (sexe in('M', 'F')))
    nested table liste_conseiller store as table_conseillers_sportifs,
    nested table liste_entrainer store as table_sportifs_antrainer,
    nested table liste_arbitrer store as table_sportifs_arbitrer,
    nested table liste_jouer store as table_sportifs_jouer;
create table sports of tsport(
      constraint pk_sport primary key(idsport))
      nested table liste_entrainer store as table_sport_entrainer,
     nested table liste_arbitrer store as table_sport_arbitrer,
     nested table liste_jouer store as table_sport_jouer,
     nested table liste_seances store as table_sport_seances;
create table arbitrer of tarbitrer(
    constraint fk_arbitrer_sportif foreign key(idsportif) references sportifs on delete cascade,
    constraint fk_arbitrer_sport foreign key(idsport) references sports on delete cascade);
create table entrainer of tentrainer(
    constraint fk_entrainer_sportif foreign key(idsportif) references sportifs on delete cascade,
    constraint fk_entrainer_sport foreign key(idsport) references sports on delete cascade)
    nested table liste_seances store as table_entrainer_seance;
create table jouer of tjouer(
    constraint fk_jouer_sportifs foreign key(idsportif) references sportifs on delete cascade,
    constraint fk_jouer_sport foreign key(idsport) references sports on delete cascade);
create table seances of tseances(
    constraint ck_jour check (jour IN ('Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi')),
    constraint fk_seances_gymnase foreign key(idgymnase) references gymnases on delete cascade,
    constraint fk_seances_entrainer foreign key(entrainer) references entrainer on delete cascade,
    constraint fk_seances_sport foreign key(idsport) references sports on delete cascade);

			/**********  qstn7  **********/

alter type tseances add member function convertir_horaire return varchar2 cascade;
create or replace type body tseances as member function convertir_horaire return varchar2
    is
    horaire varchar2(5);
    begin
    select  ((TRUNC(self.horaire)) || ':' || TRUNC(MOD(self.horaire, 1) * 100)) into horaire from dual;
    return horaire;
    end;
    end;
    /
alter type tsportifs add member function nbr_sports return integer cascade;
create or replace type body tsportifs as member function nbr_sports return integer is
    nbrsports integer;
    begin
    select cardinality(self.liste_entrainer) into nbrsports from dual;
    return nbrsports;
    end;
    end;
    /
alter type tsport add member function nbr_gymnases return integer cascade;
create or replace type body tsport as member function nbr_gymnases return integer is
    nbrgymnases integer;
    begin
    select count(distinct deref(value(c).gymnase).idgymnase) into nbrgymnases from sport p, table(value(p).liste_entrainer) e, table(value(e).liste_seances) c;
    return nbrgymnases;
    end;
    end;
    /
alter type tville add member function avg_surface return number cascade;
create or replace type body tville as member function avg_surface return number is
    avgsurface number;
    begin
    select avg(value(g).surface) into avgsurface from ville v, table(value(v).liste_gymnases) g;
    return avgsurface;
    end;
    end;
    /

			/**********  qstn8  **********/

/**********  Table ville  **********/

insert into ville values(tville('Alger centre', t_set_gymnases()));
insert into ville values(tville('Les sources', t_set_gymnases()));
insert into ville values(tville('Belouizdad', t_set_gymnases()));
insert into ville values(tville('Sidi Mhamed', t_set_gymnases()));
insert into ville values(tville('El Biar', t_set_gymnases()));
insert into ville values(tville('El Mouradia', t_set_gymnases()));
insert into ville values(tville('Hydra', t_set_gymnases()));
insert into ville values(tville('Dely Brahim', t_set_gymnases()));
insert into ville values(tville('Kouba', t_set_gymnases()));
insert into ville values(tville('Bir Mourad Raïs', t_set_gymnases()));
insert into ville values(tville('Birkhadem', t_set_gymnases()));
insert into ville values(tville('El Achour', t_set_gymnases()));
insert into ville values(tville('Bordj el kiffan', t_set_gymnases()));
insert into ville values(tville('Baba hassen', t_set_gymnases()));
insert into ville values(tville('Chéraga', t_set_gymnases()));
insert into ville values(tville('Alger', t_set_gymnases()));
insert into ville values(tville('Hussein Dey', t_set_gymnases()));
insert into ville values(tville('Béni Messous', t_set_gymnases()));
insert into ville values(tville('Bordj El Bahri', t_set_gymnases()));
insert into ville values(tville('Centre commercial-Mohamadia mall', t_set_gymnases()));
select count(*) from ville;

/**********  Table sportifs  **********/

insert into sportifs values(tsportifs(1,'BOUTAHAR','Abderahim','M',30,NULL,t_set_entrainer(),t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(2,'BOUROUBI','Anis','M',28, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(3,'BOUZIDI','Amel','F',25, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(4,'LACHEMI','Bouzid','M',32, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(5,'AAKOUB','Linda','F',22, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(6,'ABBAS','Sophia','F',30, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(7,'HADJ','Zouhir','M',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(8,'HAMADI','Hani','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(9,'ABDELMOUMEN','Nadia','F',23, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(10,'ABAD','Abdelhamid','M',23, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(11,'ABAYAHIA','Amine','M',24, (select ref(s) from sportifs s where s.idsportif='6'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(12,'ABBACI','Riad','M',24, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(13,'ABBACI','Mohamed','M',22, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(14,'ABDELOUAHAB','Lamia','F',24, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(15,'ABDEMEZIANE','Majid','M',25, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(16,'BENOUADAH','Lamine','M',24, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(17,'ACHAIBOU','Rachid','M',22, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(18,'HOSNI','Leila','F',25, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(19,'ABERKANE','Adel','M',25, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(20,'AZOUG','Racim','M',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(21,'BABACI','Mourad','M',22, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(22,'BAKIR','Ayoub','M',25, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(23,'BEHADI','Youcef','M',24, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(24,'AMARA','Nassima','F',23, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(25,'AROUEL','Lyes','M',23, (select ref(s) from sportifs s where s.idsportif='9'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(26,'BAALI','Leila','F',23, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(27,'BADI','Hatem','M',23, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(28,'RABAHI','Rabah','M',40, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(29,'ROUSSELI','Lamice','F',22, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(30,'CHIKHI','Nidal','M',24, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(31,'SETIHA','Moustapha','M',22, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(32,'COTERI','Daouad','M',23, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(33,'RAMELI','Sami','M',23, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(34,'LEHIRACHE','Oussama','M',24, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(35,'TERIKI','Yacine','M',24, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(36,'DJELOUDANE','Zinedine','M',28, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(37,'LAZARI','Malika','F',25, (select ref(s) from sportifs s where s.idsportif='44'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(38,'MESSOUNI','Ismail','M',24, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(39,'MORELI','Otheman','M',24, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(40,'FATAHI','Majid','M',23, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(41,'DELHOUME','Elina','F',22, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(42,'BEHADI','Nadir','M',23, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(43,'MATI','Dalia','F',23, (select ref(s) from sportifs s where s.idsportif='6'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(44,'ADIBOU','Ibrahim','M',28, (select ref(s) from sportifs s where s.idsportif='21'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(45,'CHALI','Karim','M',25,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(46,'DOUDOU','Islam','M',24, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(47,'Grine','Célina','F',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(48,'HEDDI','Zohra','F',23, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(49,'JADI','Sandra','F',24, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(50,'KALI','Yasser','M',22, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(51,'LAJEL','Fouad','M',24, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(52,'DANDOUR','Rami','M',22, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(53,'DEMMERA','Houcine','M',22, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(54,'ELKABBADJ','Mohammed','M',23, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(55,'FEROLI','Omer','M',23, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(56,'GUERRAOUI','Zohra','F',25, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(57,'BOUACHA','Aziz','M',25, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(58,'GUITENI','Adam','M',23, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(59,'KACI','Samia','F',23,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(60,'TIZEGHAT','Badis','M',32, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(61,'LAZARRI','Jamel','M',27, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(62,'BAZOUDI','Jaouad','M',32, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(63,'AMANI','Fadi','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(64,'LANORI','Faiza','F',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(65,'CHAADI','Mourad','M',30,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(66,'DANDANE','Mohamed','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(67,'FATTIMI','Dalila','F',26, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(68,'REGHI','Jazia','F',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(69,'MARADI','Hadjer','F',25, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(70,'BELMADI','Nadji','M',30, (select ref(s) from sportifs s where s.idsportif='9'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(71,'DELAROCHI','Racim','M',30, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(72,'MARTALI','Bouzid','M',22, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(73,'DALLIMI','Douad','M',30, (select ref(s) from sportifs s where s.idsportif='6'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(74,'OUBACHA','Adel','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(75,'SAADI','Nihal','F',39, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(76,'HALGATTI','Camelia','F',30, (select ref(s) from sportifs s where s.idsportif='21'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(77,'HIDDOUCI','Farid','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(78,'CHAOUAH','Jamel','M',30,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(79,'HANDI','Jaouad','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(80,'HOCHET','Ramezi','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(81,'DROULLONI','Jaouida','F',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(82,'HOULEMI','Lyes','M',40, (select ref(s) from sportifs s where s.idsportif='14'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(83,'LOUATI','Ahmed','M',30, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(84,'SALLADj','Miloud','M',28, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(85,'HAMARI','Anes','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(86,'GALLOTI','Boualem','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(87,'KASBADJI','Fateh','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(88,'JENOURI','Rachid','M',30, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(89,'RIHABI','Jamel','M',30,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(90,'DERARNI','Nadir','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(91,'BATERAOUI','Zinedine','M',30, (select ref(s) from sportifs s where s.idsportif='98'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(92,'HADJI','Jamel','M',22, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(93,'CAUCHARDI','Nabil','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(94,'LEROUDI','Moussa','M',36, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(95,'ESTANBOULI','Mazine','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(96,'JANID','Lamine','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(97,'BONHOMMANE','Bassim','M',30,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(98,'RIADI','Walid','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(99,'BONETI','Djalal','M',32,NULL, t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(100,'LESOIFI','Djamil','M',30, (select ref(s) from sportifs s where s.idsportif='9'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(101,'SWAMI','Esslam','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(102,'DAOUDI','Adel','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(103,'LAAMOURI','Nasssim','M',30, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(104,'SEHIER','Dihia','F',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(105,'STITOUAH','Fouad','M',30, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(106,'BAADI','Hani','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(107,'BOURAS','Nazim','M',30, (select ref(s) from sportifs s where s.idsportif='9'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(108,'AIT AMARA','Salim','M',30, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(109,'SAGOU','Bassel','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(110,'ROULLADI','Aissa','M',30, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(111,'BOUTINE','Mohamed','M',30, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(112,'LOUATI','Islam','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(113,'AID','Naim','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(114,'MICHALIKH','Asma','F',22, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(115,'LEMOUSSI','Amine','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(116,'BELIFA','Samia','F',30, (select ref(s) from sportifs s where s.idsportif='8'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(117,'FERRIRA','Manel','F',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(118,'IGHOLI','Lyes','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(119,'GUEMEZ','Jaouad','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(120,'LECOM','Aissa','M',30, (select ref(s) from sportifs s where s.idsportif='6'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(121,'HOUAT','Aziz','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(122,'BEQUETA','Aicha','F',30, (select ref(s) from sportifs s where s.idsportif='6'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(123,'RATENI','Walid','M',30, (select ref(s) from sportifs s where s.idsportif='6'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(124,'TOUAT','Yasmine','F',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(125,'JALONI','Aimad','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(126,'DEBOUBA','yasser','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(127,'GASTAB','Chouaib','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(128,'GIRONI','Younes','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(129,'DABONI','Rachid','M',30, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(130,'LACHOUBI','Kamel','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(131,'GALLOI','Nadira','F',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(132,'DORONI','Yanis','M',30, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(133,'LENOUCHI','Youcef','M',30, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(134,'LERICHE','Hadi','M',30, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(135,'MANSOUR','Lamine','M',30, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(136,'LABOULAIS','Fadia','F',26, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(137,'DOUDOU','Faiza','F',26, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(138,'MAALEM','Lamia','F',26, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(139,'BESNARD','Salma','F',26, (select ref(s) from sportifs s where s.idsportif='4'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(140,'BELHAMID','Hadjer','F',26, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(141,'BOUAAZA','Asma','F',26, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(142,'CORCHI','Melissa','F',26, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(143,'BELAID','Jaouida','F',26, (select ref(s) from sportifs s where s.idsportif='5'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(144,'GASMI','Souad','F',26, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(145,'LAAMARA','Maria','F',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(146,'DABOUB','Ramezi','M',25, (select ref(s) from sportifs s where s.idsportif='3'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(147,'HASSINI','Nadia','F',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(148,'KALOUNE','Maria','F',27, (select ref(s) from sportifs s where s.idsportif='1'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(149,'BELHAOUA','Besma','F',27, (select ref(s) from sportifs s where s.idsportif='7'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(150,'BELAID','Fouad','M',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
insert into sportifs values(tsportifs(151,'HENDI','Mouad','M',25, (select ref(s) from sportifs s where s.idsportif='2'), t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_conseiller()));
select count(*) from sportifs;

/**********  Table sports  **********/

INSERT INTO Sports VALUES(tsport(1,'Basket ball',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(2,'Volley ball',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(3,'Hand ball',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(4,'Tennis',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(5,'Hockey',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(6,'Badmington',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(7,'Ping pong',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(8,'Football',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
INSERT INTO Sports VALUES(tsport(9,'Boxe',t_set_entrainer(), t_set_arbitrer(), t_set_jouer(), t_set_seances()));
select count(*) from sports;

/**********  Table gymnases  **********/

INSERT INTO Gymnases VALUES(tgymnases(1,'Five Gym Club','Boulevard Mohamed 5',(select ref(v) from ville v where v.ville='Alger centre'),200,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(2,'Mina Sport','28 impasse musette les sources',(select ref(v) from ville v where v.ville='Les sources'),450,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(3,'Aït Saada','Belouizdad',(select ref(v) from ville v where v.ville='Belouizdad'),400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(4,'Bahri Gym','Rue Mohamed Benzineb',(select ref(v) from ville v where v.ville='Sidi Mhamed'),500,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(5,'Ladies First','3 Rue Diar Naama N° 03',(select ref(v) from ville v where v.ville='El Biar'),620,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(6,'C.T.F Club','Rue Sylvain FOURASTIER', (select ref(v) from ville v where v.ville='El Mouradia'),400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(7,'Body Fitness Center','Rue Rabah Takdjourt',(select ref(v) from ville v where v.ville='Alger centre'),360,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(8,'Club Hydra Forme','Rue de l''Oasis', (select ref(v) from ville v where v.ville='Hydra'),420,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(9,'Profitness Dely Brahim','26 Bois des Cars 3', (select ref(v) from ville v where v.ville='Dely Brahim'), 620,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(10,'CLUB SIFAKS','Rue Ben Omar 31', (select ref(v) from ville v where v.ville='Kouba'),400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(11,'Gym ZAAF Club','19 Ave Merabet Athmane', (select ref(v) from ville v where v.ville='El Mouradia'), 300,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(12,'GYM power','villa N°2, Chemin Said Hamdine', (select ref(v) from ville v where v.ville='Bir Mourad Raïs'), 480,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(13,'Icosium sport','Rue ICOSUM', (select ref(v) from ville v where v.ville='Hydra'),200,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(14,'GIGA Fitness','res, Rue Hamoum Tahar', (select ref(v) from ville v where v.ville='Birkhadem'), 500,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(15,'AC Fitness Et Aqua','Lotissement FAHS lot A n 12 parcelle 26', (select ref(v) from ville v where v.ville='Birkhadem'),400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(16,'MELIA GYM','Résidence les deux bassins Sahraoui local N° 03', (select ref(v) from ville v where v.ville='El Achour'), 600,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(17,'Sam Gym Power','Rue Mahdoud BENKHOUDJA', (select ref(v) from ville v where v.ville='Kouba'), 400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(18,'AQUAFORTLAND SPA','Bordj el kiffan',(select ref(v) from ville v where v.ville='Bordj el kiffan'),450,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(19,'GoFitness','Lotissement el louz n°264', (select ref(v) from ville v where v.ville='Baba hassen'), 500,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(20,'Best Body Gym','Cité Alioua Fodil',(select ref(v) from ville v where v.ville='Chéraga'), 400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(21,'Power house gym','Cooperative Amina 02 Lot 15',(select ref(v) from ville v where v.ville='Alger'),400,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(22,'POWER ZONE GYM','Chemin Fernane Hanafi', (select ref(v) from ville v where v.ville='Hussein Dey'), 500,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(23,'World Gym','14 Boulevard Ibrahim Hadjress',(select ref(v) from ville v where v.ville='Béni Messous'),520,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(24,'Moving Club','Bordj El Bahri',(select ref(v) from ville v where v.ville='Bordj El Bahri'),450,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(25,'Tiger gym','Route de Bouchaoui', (select ref(v) from ville v where v.ville='Chéraga'), 620,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(26,'Lion CrossFit','Centre commercial-Mohamadia mall',(select ref(v) from ville v where v.ville='Mohammadia'),600,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(27,'Étoile sportive','Saoula',(select ref(v) from ville v where v.ville='Saoula'),350,t_set_seances()));
INSERT INTO Gymnases VALUES(tgymnases(28,'Fitness life gym','El Harrach',(select ref(v) from ville v where v.ville='El Harrach'),400,t_set_seances()));
select count(*) from gymnases;

/**********  Table arbitrer  **********/

INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='5'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='5'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='8'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='6'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='7'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='7'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='9'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='5'),(select ref(a) from sports a where a.idsport='7'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='5'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='7'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='3'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='5'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='19'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='20'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='29'),(select ref(a) from sports a where a.idsport='7'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='7'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='6'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='59'),(select ref(a) from sports a where a.idsport='4'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='2'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='94'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='98'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='105'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='149'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='151'),(select ref(a) from sports a where a.idsport='1'));
INSERT INTO Arbitrer VALUES((select ref(v) from sportifs v where v.idsportif='151'),(select ref(a) from sports a where a.idsport='3'));
select count(*) from arbitrer;

/**********  Table jouer  **********/

INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='5'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='5'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='5'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='5'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='9'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='9'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='9'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='10'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='10'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='10'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='10'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='11'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='11'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='11'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='12'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='12'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='12'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='13'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='13'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='13'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='14'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='14'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='14'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='15'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='15'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='15'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='16'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='16'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='17'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='17'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='17'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='18'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='19'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='19'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='19'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='20'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='20'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='20'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='20'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='20'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='21'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='21'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='21'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='21'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='22'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='22'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='22'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='22'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='23'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='23'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='23'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='24'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='24'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='24'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='24'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='25'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='25'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='25'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='25'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='25'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='26'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='26'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='26'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='26'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='27'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='27'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='27'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='27'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='27'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='28'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='28'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='28'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='28'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='28'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='29'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='29'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='29'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='29'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='30'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='30'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='30'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='30'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='31'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='31'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='31'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='31'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='33'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='33'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='33'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='33'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='34'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='34'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='34'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='34'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='36'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='36'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='36'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='36'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='37'),(select ref(a) from sports a where a.idsport='2')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='38'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='38'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='38'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='39'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='39'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='41'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='41'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='42'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='42'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='42'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='43'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='43'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='43'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='44'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='44'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='44'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='45'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='45'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='46'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='46'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='47'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='48'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='48'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='48'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='49'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='49'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='50'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='50'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='50'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='50'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='51'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='51'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='51'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='51'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='52'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='52'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='52'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='52'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='53'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='53'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='53'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='53'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='54'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='54'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='54'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='55'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='55'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='55'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='56'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='56'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='57'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='57'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='58'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='58'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='58'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='58'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='59'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='59'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='59'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='61'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='62'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='63'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='63'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='63'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='64'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='65'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='66'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='67'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='67'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='68'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='69'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='69'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='69'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='70'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='70'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='71'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='71'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='72'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='72'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='72'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='72'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='73'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='73'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='74'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='74'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='75'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='75'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='76'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='77'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='77'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='77'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='78'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='79'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='80'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='80'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='80'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='82'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='83'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='83'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='83'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='84'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='84'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='85'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='85'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='85'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='86'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='86'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='87'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='87'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='88'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='88'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='88'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='89'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='89'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='90'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='90'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='91'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='91'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='91'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='92'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='92'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='93'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='94'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='94'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='94'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='94'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='95'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='96'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='96'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='97'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='97'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='98'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='98'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='98'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='98'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='99'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='100'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='100'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='101'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='101'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='101'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='102'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='102'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='103'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='103'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='104'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='104'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='105'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='105'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='105'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='105'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='106'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='107'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='108'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='108'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='108'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='109'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='109'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='109'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='109'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='110'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='110'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='110'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='111'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='111'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='112'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='112'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='113'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='113'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='114'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='114'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='114'),(select ref(a) from sports a where a.idsport='6')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='115'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='118'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='118'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='118'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='119'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='120'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='120'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='121'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='122'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='123'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='123'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='123'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='123'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='124'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='125'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='125'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='125'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='126'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='126'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='127'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='127'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='128'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='128'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='129'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='129'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='129'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='130'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='132'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='132'),(select ref(a) from sports a where a.idsport='7')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='132'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='133'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='134'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='135'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='135'),(select ref(a) from sports a where a.idsport='8')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='136'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='137'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='138'),(select ref(a) from sports a where a.idsport='3')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='138'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='139'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='140'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='141'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='142'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='143'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='144'),(select ref(a) from sports a where a.idsport='4')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='149'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='151'),(select ref(a) from sports a where a.idsport='1')));
INSERT INTO Jouer VALUES(tjouer((select ref(v) from sportifs v where v.idsportif='151'),(select ref(a) from sports a where a.idsport='3')));
select count(*) from jouer;

/**********  Table entrainer  **********/

INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='1'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='3'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='5'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='1'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='1'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='3'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='4'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='5'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='2'),(select ref(a) from sports a where a.idsport='9'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='1'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='3'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='3'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='1'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='4'),(select ref(a) from sports a where a.idsport='9'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='5'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='6'),(select ref(a) from sports a where a.idsport='9'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='3'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='5'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='7'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='29'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='30'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='31'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='32'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='35'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='36'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='38'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='40'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='48'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='50'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='56'),(select ref(a) from sports a where a.idsport='6'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='57'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='57'),(select ref(a) from sports a where a.idsport='4'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='58'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='58'),(select ref(a) from sports a where a.idsport='4'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='59'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='59'),(select ref(a) from sports a where a.idsport='4'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='4'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='60'),(select ref(a) from sports a where a.idsport='7'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='61'),(select ref(a) from sports a where a.idsport='2'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='61'),(select ref(a) from sports a where a.idsport='4'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='149'),(select ref(a) from sports a where a.idsport='1'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='151'),(select ref(a) from sports a where a.idsport='1'),t_set_seances()));
INSERT INTO Entrainer VALUES(tentrainer((select ref(v) from sportifs v where v.idsportif='151'),(select ref(a) from sports a where a.idsport='3'),t_set_seances()));
select count(*) from entrainer;

/**********  Table seances  **********/

INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Samedi',9.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='1' AND e.idsport.idsport ='3'),'Lundi',9.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='1' AND e.idsport.idsport ='3'),'Lundi',10.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='1' AND e.idsport.idsport ='3'),'Lundi',11.3,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='1' AND e.idsport.idsport ='3'),'Lundi',14.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='1' AND e.idsport.idsport ='3'),'Lundi',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='1' AND e.idsport.idsport ='3'),'Lundi',19.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Dimanche',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Dimanche',19.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Mardi',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Mercredi',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Samedi',15.3,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Samedi',16.3,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='2' AND e.idsport.idsport ='3'),'Samedi',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Jeudi',20.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Lundi',14.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Lundi',18.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Lundi',19.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Lundi',20.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='1'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mercredi',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='2'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='3'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Mercredi',11.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='3'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='3'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Jeudi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='4'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Vendredi',10.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='4'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Mercredi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='5'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='5'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Jeudi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='6'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Vendredi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='6'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'jeudi',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='8'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='8'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='8'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Vendredi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='8'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Samedi',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='8'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Vendredi',14.0,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='9'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Samedi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='10'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Samedi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='10'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Dimanche',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='10'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Dimanche',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='12'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='13'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Dimanche',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='13'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Mercredi',20.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='13'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Lundi',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='14'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Mardi',10.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='14'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='15'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='16'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='16'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Lundi',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='16'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Lundi',18.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='16'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'lundi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='16'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Lundi',20.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='16'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Mercredi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='17'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='2'),'Samedi',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='17'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='2'),'Vendredi',17.3,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='17'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='17'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Dimanche',18.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='17'),(select ref(a) from sports a where a.idsport='3'),(select ref(e) from entrainer e where e.idsportif.idsportif ='3' AND e.idsport.idsport ='3'),'Mardi',20.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='17'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mardi',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='18'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='18'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Mardi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='18'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mercredi',14.0,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='18'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mercredi',16.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='19'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='20'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Mercredi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='21'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Lundi',16.3,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='21'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='60' AND e.idsport.idsport ='2'),'Mardi',19.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='21'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mercredi',17.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='22'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Mardi',10.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='24'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Jeudi',9.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='24'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Mercredi',10.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='25'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Dimanche',18.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='27'),(select ref(a) from sports a where a.idsport='2'),(select ref(e) from entrainer e where e.idsportif.idsportif ='57' AND e.idsport.idsport ='2'),'Jeudi',10.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='27'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mercredi',14.0,120));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='27'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mercredi',17.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='1'),(select ref(e) from entrainer e where e.idsportif.idsportif ='149' AND e.idsport.idsport ='1'),'Lundi',9.0,30));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Dimanche',14.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Dimanche',15.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Dimanche',16.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='6' AND e.idsport.idsport ='5'),'Dimanche',17.0,60));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Mardi',18.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Samedi',18.0,90));
INSERT INTO Seances VALUES(tseances((select ref(g) from gymnases g where g.idgymnase='28'),(select ref(a) from sports a where a.idsport='5'),(select ref(e) from entrainer e where e.idsportif.idsportif ='7' AND e.idsport.idsport ='5'),'Vendredi',18.0,90));
select count(*) from seances;

/**********  Remplissage des collections vide  **********/

update ville set liste_gymnases = cast(multiset(select ref(g) from gymnases g  where deref(ville).ville = ville.ville) as t_set_gymnases);
update sportifs set liste_entrainer = cast(multiset(select ref(e) from entrainer e  where deref(idsportif).idsportif = sportifs.idsportif) as t_set_entrainer);
update sportifs set liste_arbitrer = cast(multiset(select ref(a) from arbitrer a  where deref(idsportif).idsportif = sportifs.idsportif) as t_set_arbitrer);
update sportifs set liste_jouer = cast(multiset(select ref(j) from jouer j  where deref(idsportif).idsportif = sportifs.idsportif) as t_set_jouer);
update sportifs set liste_conseiller = cast(multiset(select ref(c) from sportifs c  where deref(idsportifconseiller).idsportif = sportifs.idsportif) as t_set_conseiller);
update gymnases set liste_seances = cast(multiset(select ref(s) from seances s where deref(idgymnase).idgymnase = gymnases.idgymnase) as t_set_seances);
UPDATE entrainer SET liste_seances = CAST(MULTISET(SELECT REF(s) FROM seances s WHERE DEREF(s.entrainer.idsportif).idsportif = DEREF(entrainer.idsportif).idsportif) AS t_set_seances);

			/**********  qstn9  **********/

SELECT idsportif, nom, prenom FROM sportifs WHERE age BETWEEN 20 AND 30;

			/**********  qstn10  **********/

SELECT v.ville, AVG(g.surface) as superficie_moyenne FROM ville v JOIN gymnases g ON g.ville = REF(v) GROUP BY v.ville;

			/**********  qstn11  **********/

SELECT idsportif, nom, prenom FROM sportifs WHERE EXISTS ( SELECT * FROM TABLE(liste_conseiller));

			/**********  qstn12  **********/

SELECT s.idsportif, s.nom, s.prenom
FROM sportifs s
JOIN entrainer e ON s.idsportif = e.idsportif.idsportif
WHERE e.idsport.idsport = (SELECT idsport FROM sports WHERE libelle = 'Hand ball')
INTERSECT
SELECT s.idsportif, s.nom, s.prenom
FROM sportifs s
JOIN entrainer e ON s.idsportif = e.idsportif.idsportif
WHERE e.idsport.idsport = (SELECT idsport FROM sports WHERE libelle = 'Basket ball');

			/**********  qstn13  **********/

SELECT idsportif, nom, prenom FROM sportifs WHERE age = (SELECT MIN(age) FROM sportifs);


