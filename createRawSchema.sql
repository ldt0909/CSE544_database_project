create table Pub (k text, p text);
create table Field (k text, i text, p text, v text);
copy Pub from '/Users/dantili/Desktop/hw1/pubFile.txt';
copy Field from '/Users/dantili/Desktop/hw1/fieldFile.txt';
