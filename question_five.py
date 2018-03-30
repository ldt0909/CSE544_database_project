import psycopg2

conn = psycopg2.connect("dbname=dblp user=dantili")
cur = conn.cursor()
cur.execute("with tmp as (select ahp1.authorid, count(*)from author_has_pub2 ahp1, author_has_pub2 ahp2 where ahp1.pubid = ahp2.pubid and ahp1.authorid != ahp2.authorid group by ahp1.authorid) select tmp.count, count(*) from tmp group by tmp.count order by tmp.count;")
result = cur.fetchall();
with open("histograph_coauthor.csv", "w") as f:
    for row in result:
        f.write(str(row[0]) + ", " + str(row[1]) + "\n")

cur.execute("with tmp as (select authorid, count(*) from author_has_pub2 group by authorid) select count as number_of_publication, count(*) as number_of_author from tmp group by tmp.count order by number_of_publication;")
result = cur.fetchall();
with open("histograph_publication.csv", "w") as f:
    for row in result:
        f.write(str(row[0]) + ", " + str(row[1]) + "\n")

