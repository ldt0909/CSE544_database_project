with tmp as (select min(a.name) as name, ahp.authorid as id , count(*) as count 
from author2 a, author_has_pub2 ahp, inproceedings2 ip
where a.authorid = ahp.authorid and ahp.pubid = ip.pubid and
ip.booktitle='STOC'
group by ahp.authorid) select substring(a.homepage from 'https?://[^/]*\.([^\.^/]*)/') as institution, sum(tmp.count) as sum from author2 a, tmp where tmp.id = a.authorid and a.homepage is not null group by institution order by sum desc limit 20;

/*
 institution | sum  
-------------+------
 edu         | 1741
 org         |  861
 il          |  420
 info        |  297
 com         |  280
 ca          |  126
 de          |   98
 gov         |   63
 dk          |   42
 nl          |   40
 fr          |   35
 ch          |   32
 it          |   30
 jp          |   30
 in          |   24
 uk          |   21
 hu          |   18
 hk          |   17
 net         |   15
 cz          |    8

The result is shown above. The result is interesting because you can find the number of publications each institution
published in STOC. From the result we can see, there are 428 publications from IL, which is Isreal. 
I'm surprised because it is even more than 'info's , 'com's and gov's. I think in some way , it shows the Isreal has significant 
influence in cs research field.

*/ 
