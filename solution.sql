select p, count(*) from pub group by p;

/* 2.2 simple*/
with tmp as (select f.p as field, p.p as pub from Pub p inner join Field f using(k) group by f.p, p.p order by f.p, p.p)
select field from tmp group by field having count(*) >=8;

/* 2.2 complicated*/
with tmp as (with tmp as (select distinct p from Pub)
	select f.p as field, p.p as pub, (select count(*) from tmp) from Pub p inner join Field f using(k) group by f.p, p.p order by f.p, p.p)
select tmp.field from tmp group by field, count having count(*) = tmp.count;

/*create index*/
create index PubK on Pub (k);
create index FieldK on Field (k);



===============================


create table author (AuthorID          int primary key, 
                     Name              varchar(100),
                     Homepage          varchar(1000)
                     );

select distinct f.v into tmp from field f where f.p = 'author';
select f.v as Name, MIN(f2.v) as Homepage into tmp2 from Field f, Field f2, Pub p where f.k=p.k and f.k=f2.k and p.p='www' and f.p='author' and f2.p='url' and f2.k like 'homepages%' group by f.v;
create sequence q;
insert into author select nextval('q') as AuthorID, tmp.v, tmp2.Homepage from tmp full outer join tmp2 on tmp.v=tmp2.name;
drop sequence q; 
drop table tmp;
drop table tmp2;

alter table author
add unique (Name);

create table publication (
Pubid      int primary key,
pubkey     varchar(10000),
title      varchar(10000),
year       varchar(10000)
 );

select k, min(v) as title into tmp from field f where f.p='title' group by k;
select k, min(v) as year into tmp2 from field f where f.p = 'year' group by k;
create sequence q;
insert into publication (select nextval('q') as pubid, pub.k, tmp.title, tmp2.year from pub full outer join tmp on pub.k = tmp.k full outer join tmp2 on pub.k = tmp2.k);
drop sequence q; 
drop table tmp;
drop table tmp2;


alter table publication
add unique (pubkey);

create table author_has_pub (
Pubid      int,
authorid   int,
primary key (Pubid, authorid)
 );
insert into author_has_pub 
	select distinct p.pubid, a.authorid  
	from field f, publication p, author a 
	where p = 'author' and f.k = p.pubkey and f.v = a.name;

create table book(
pubid     int primary key,
Publisher  varchar(1000),
isbn       varchar(1000)
 );

select k, min(v) as publisher into tmp from field f where f.p='publisher' group by k; 
select k, min(v) as isbn into tmp2 from field f where f.p='isbn' group by k; 
insert into book (select distinct publication.pubid as pubid, tmp.publisher, tmp2.isbn from publication join pub on publication.pubkey = pub.k left outer join tmp on publication.pubkey = tmp.k left outer join tmp2 on publication.pubkey = tmp2.k where pub.p = 'book');


create table incollection  (
 pubid         int primary key,
 booktitle              varchar(1000),
 publisher              varchar(1000),
 isbn                   varchar(1000)
 );

select k, min(v) as booktitle into tmp3 from field f where f.p='booktitle' group by k;
insert into incollection (select distinct publication.pubid as pubid, tmp3.booktitle, tmp.publisher, tmp2.isbn from publication join pub on publication.pubkey = pub.k left outer join tmp on publication.pubkey = tmp.k left outer join tmp2 on publication.pubkey = tmp2.k left outer join tmp3 on publication.pubkey = tmp3.k where pub.p = 'incollection');

create table article (
pubid              int primary key,
Journal                varchar(1000),
month                  varchar(1000),
volume                 varchar(1000),
number                 varchar(100)
);

select k, min(v) as journal into tmp4 from field f where f.p='journal' group by k;
select k, min(v) as month into tmp5 from field f where f.p='month' group by k;
select k, min(v) as volume into tmp6 from field f where f.p='volume' group by k;
select k, min(v) as number into tmp7 from field f where f.p='number' group by k;
insert into article (select distinct publication.pubid as pubid, tmp4.journal, tmp5.month, tmp6.volume, tmp7.number from publication join pub on publication.pubkey = pub.k left outer join tmp4 on publication.pubkey = tmp4.k left outer join tmp5 on publication.pubkey = tmp5.k left outer join tmp6 on publication.pubkey = tmp6.k left outer join tmp7 on publication.pubkey = tmp7.k where pub.p = 'article');

create table inproceedings (
pubid       int primary key,
booktitle             varchar(1000),
editor                varchar(1000)
);

select k, min(v) as editor into tmp8 from field f where f.p='editor' group by k;
insert into inproceedings (select distinct publication.pubid as pubid, tmp3.booktitle, tmp8.editor from publication join pub on publication.pubkey = pub.k left outer join tmp3 on publication.pubkey = tmp3.k left outer join tmp8 on publication.pubkey = tmp8.k where pub.p = 'inproceedings');

drop table tmp;
drop table tmp2;
drop table tmp3;
drop table tmp4;
drop table tmp5;
drop table tmp6;
drop table tmp7;
drop table tmp8;

/*foreign key*/
alter table author_has_pub
add foreign key (pubid)
references publication(pubid);

alter table author_has_pub
add foreign key (authorid)
references author(authorid);

alter table book
add foreign key (pubid)
references publication (pubid);

alter table article
add foreign key (pubid)
references publication (pubid);

alter table incollection
add foreign key (pubid)
references publication (pubid);

alter table inproceedings
add foreign key (pubid)
references publication (pubid);


=======================
/*4.1*/
select min(a.name) as name, ahp.authorid as id , count(*) as count 
from author a, author_has_pub ahp 
where a.authorid = ahp.authorid  
group by ahp.authorid order by count desc limit 20;
/*4.2*/

select min(a.name) as name, ahp.authorid as id , count(*) as count
from author2 a, author_has_pub2 ahp, inproceedings2 ip
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle='STOC'
group by ahp.authorid order by count desc limit 20;

select min(a.name) as name, ahp.authorid as id , count(*) as count
from author2 a, author_has_pub2 ahp, inproceedings2 ip
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle like '%PODS%'
group by ahp.authorid order by count desc limit 20;

select min(a.name) as name, ahp.authorid as id , count(*) as count
from author2 a, author_has_pub2 ahp, inproceedings2 ip
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle like '%SIGMOD Conference%'
group by ahp.authorid order by count desc limit 20;


/*4.3*/

select min(a.name) as name, ahp.authorid as id
from author a, author_has_pub ahp, inproceedings ip
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle like '%SIGMOD Conference%'
group by ahp.authorid having count(*) >= 10 except
select min(a.name) as name, ahp.authorid as id 
from author a, author_has_pub ahp, inproceedings ip 
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle like '%PODS%'
group by ahp.authorid;

select min(a.name) as name, ahp.authorid as id
from author a, author_has_pub ahp, inproceedings ip
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle like '%PODS%'
group by ahp.authorid having count(*) >= 5 except
select min(a.name) as name, ahp.authorid as id 
from author a, author_has_pub ahp, inproceedings ip 
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle like '%SIGMOD Conference%'
group by ahp.authorid;

/*4.4*/
select p.year, count(*) into tmp from publication p group by year order by year;
select year, SUM(count) over (order by year rows between 0 preceding and 9 following) from tmp;
drop table tmp;

/*4.5*/
select ahp1.authorid, count(*) into tmp from author_has_pub ahp1, author_has_pub ahp2 where ahp1.pubid = ahp2.pubid and ahp1.authorid != ahp2.authorid group by ahp1.authorid;
select * from tmp order by count desc limit 20;
drop table tmp;

/*4.6*/
select ahp.authorid, p.year, count(*) as n into tmp from author_has_pub ahp, publication p where ahp.pubid = p.pubid group by ahp.authorid, p.year;
select distinct year into tmp2 from publication order by year;
select tmp.authorid, tmp2.year, sum(tmp.n) as n into tmp3 from tmp, tmp2 where tmp.year >= tmp2.year and cast(tmp.year as integer) < cast(tmp2.year as integer) + 10 group by tmp.authorid, tmp2.year;
select tmp3.year, max(tmp3.n) into tmp4 from tmp3 group by year order by year;
select distinct tmp4.year, author.name, tmp4.max from tmp4, tmp3, author where author.authorid = tmp3.authorid and tmp3.n = tmp4.max and tmp4.year = tmp3.year order by year;

/*4.7*/

with tmp as (select min(a.name) as name, ahp.authorid as id , count(*) as count
	from author2 a, author_has_pub2 ahp, inproceedings2 ip
	where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
	ip.booktitle='STOC'
	group by ahp.authorid) 
select substring(a.homepage from 'https?://([^/]*)/') as institution, sum(tmp.count) as sum 
from author a, tmp where tmp.id = a.authorid and a.homepage is not null group by institution order by sum desc limit 20;

/*5*/
with tmp as (select ahp1.authorid, count(*)from author_has_pub ahp1, author_has_pub ahp2 where ahp1.pubid = ahp2.pubid and ahp1.authorid != ahp2.authorid group by ahp1.authorid) select tmp.count, count(*) from tmp group by tmp.count order by tmp.count;

with tmp as (select authorid, count(*) from author_has_pub group by authorid) select count as number_of_publication, count(*) as number_of_author from tmp group by tmp.count order by number_of_publication;


