//Load Author
CREATE CONSTRAINT author_name_unique FOR (author:Author) REQUIRE author.name IS UNIQUE

LOAD CSV WITH HEADERS FROM 'file:///author.csv' AS row
FIELDTERMINATOR "|" WITH row
WITH row WHERE row.name IS NOT NULL
MERGE (a:Author {name: row.name, orcid:row.orcid});

//Load Conference
CREATE CONSTRAINT conference_name_unique ON (conf:Conference) ASSERT conf.name IS UNIQUE

LOAD CSV WITH HEADERS FROM 'file:///conferences.csv' AS row
FIELDTERMINATOR "|"
WITH row WHERE row.name IS NOT NULL
MERGE (con:Conference {name: row.name, year: row.year});

//Load Journal
CREATE CONSTRAINT journal_name_unique FOR (j:Journal) REQUIRE j.name IS UNIQUE

LOAD CSV WITH HEADERS FROM 'file:///journals.csv' AS row
WITH row WHERE row.name IS NOT NULL
MERGE (j:Journal {name: row.name});

//Load Publication
CREATE CONSTRAINT publication_title_unique FOR (pc:Publication) REQUIRE pc.doi IS UNIQUE

LOAD CSV WITH HEADERS FROM 'file:///publications.csv' AS row
FIELDTERMINATOR '|'
WITH row WHERE row.doi IS NOT NULL
CREATE (p:Publication {
                        doi: row.id,
                        title: row.title,
						year: coalesce(row.year, ''),
					    pages: coalesce(row.pages, ''), 
                        isbn: coalesce(row.isbn, ''), 
                        publisher: coalesce(row.publisher, ''), 
                        doc_type: row.doc_type});

//Load Publisher
CREATE CONSTRAINT publisher_name_unique ON (ps:Publisher) ASSERT ps.name IS UNIQUE

LOAD CSV WITH HEADERS FROM 'file:///publisher.csv' AS row
WITH row WHERE row.name IS NOT NULL
MERGE (ps:Publisher {name: row.name});

//Load Institution
CREATE CONSTRAINT institution_name_unique FOR (inst:Institution) REQUIRE inst.institution IS UNIQUE

LOAD CSV WITH HEADERS FROM 'file:///institution.csv' AS row
FIELDTERMINATOR '|'
WITH row WHERE row.institution IS NOT NULL
CREATE (inst:Institution {  wr: row.world_rank
                            name: row.institution,
                            country: row.country,
                            nr: row.national_rank,
                            qe: row.quality_of_education, 
                            score: row.scor});

###RELATIONS###

//Load Relation Citation 
LOAD CSV WITH HEADERS FROM "file:///citationFAKE.csv" AS row
MATCH (a:Publication{doi:row.document}),(b:Publication{doi:row.cite})
CREATE (a)-[:CITE]->(b)

//Load Relation Write
load csv with headers from "file:///relationship.csv" AS row FIELDTERMINATOR "|" 
match(a:Author{name:row.name})
match(p:Publication{doi:row.id})
create (a)-[:WROTE{order:row.author_order}]->(p)

//Load Relation Hold   
LOAD CSV WITH HEADERS FROM "file:///conferences_relationship.csv" AS row FIELDTERMINATOR "|"
MATCH (a:Publication{doi:row.id})
MATCH (b:Conference{name:row.name})
CREATE (a)-[:HOLD]->(b)

//Load Relation Journal
LOAD CSV WITH HEADERS FROM "file:///journals_relationship.csv" AS row FIELDTERMINATOR "|"
MATCH (a:Publication{doi:row.id}),(b:Journal{name:row.name})
CREATE (a)-[:CONTAINED]->(b)

//Load Relation Publisher
LOAD CSV WITH HEADERS FROM "file:///publisher_relationship.csv" AS row FIELDTERMINATOR "|"
MATCH (a:Publication{doi:row.id})
MATCH (b:Publisher{name:row.name})
CREATE (a)-[:CONTAINED]->(b)

//Load keywords
LOAD CSV WITH HEADERS FROM "file:///keywords.csv" AS row
FIELDTERMINATOR ";"
MATCH (p:Publication {doi: row.pubID})
MERGE (k:Keyword {name: row.keyword})
MERGE (p)-[:KEYWORD]->(k)

//Load Author_Inst relationship
LOAD CSV WITH HEADERS FROM "file:///work_rel.csv" AS row
FIELDTERMINATOR "|"
MATCH (a:Author {name: row.name})
MATCH (inst:Institution {institution: row.university})
CREATE (a)-[:WORK]->(inst)