
CREATE VIEW latestGood AS
SELECT "Location ID"
,"Location Local Authority"
,"Latest Rating"
,"Provider ID"
,"Provider Name"
FROM Locations
WHERE "Service / Population Group"='Overall'
AND "Key Question"='Overall'
AND "Latest Rating"='Good'
ORDER BY "Location Local Authority";

CREATE VIEW latestOutstanding AS
SELECT "Location ID"
,"Location Local Authority"
,"Latest Rating"
,"Provider ID"
,"Provider Name"
FROM Locations
WHERE "Service / Population Group"='Overall'
AND "Key Question"='Overall'
AND "Latest Rating"='Outstanding'
ORDER BY "Location Local Authority";

CREATE VIEW latestInadequate AS
SELECT "Location ID"
,"Location Local Authority"
,"Latest Rating"
,"Provider ID"
,"Provider Name"
FROM Locations
WHERE "Service / Population Group"='Overall'
AND "Key Question"='Overall'
AND "Latest Rating"='Inadequate'
ORDER BY "Location Local Authority";

CREATE VIEW latestRequiresImprovement AS
SELECT "Location ID"
,"Location Local Authority"
,"Latest Rating"
,"Provider ID"
,"Provider Name"
FROM Locations
WHERE "Service / Population Group"='Overall'
AND "Key Question"='Overall'
AND "Latest Rating"='Requires improvement'
ORDER BY "Location Local Authority";

CREATE VIEW "latestGoodCount"
AS
SELECT 
       "Location Local Authority", 
              COUNT ("Latest Rating") AS "ratingCount"
              FROM   "latestGood"
       GROUP  BY "Location Local Authority";

CREATE VIEW "latestInadequateCount"
AS
SELECT 
       "Location Local Authority", 
              COUNT ("Latest Rating") AS "ratingCount"
              FROM   "latestInadequate"
       GROUP  BY "Location Local Authority";

CREATE VIEW "latestOutstandingCount"
AS
SELECT 
       "Location Local Authority", 
              COUNT ("Latest Rating") AS "ratingCount"
              FROM   "latestOutstanding"
       GROUP  BY "Location Local Authority";

CREATE VIEW "latestRequiresImprovementCount"
AS
SELECT 
       "Location Local Authority", 
              COUNT ("Latest Rating") AS "ratingCount"
              FROM   "latestRequiresImprovement"
       GROUP  BY "Location Local Authority";

CREATE VIEW "uniqLocalAuthorities"
AS
SELECT DISTINCT "Location Local Authority" AS "localAuthority"
FROM   "Locations"
ORDER  BY "localAuthority";

CREATE VIEW ratingsByLocalAuthority AS
SELECT uniqLocalAuthorities."localAuthority" 
, latestOutstandingCount.ratingCount AS outstandingCount
, latestGoodCount.ratingCount AS goodCount
, latestRequiresImprovementCount.ratingCount AS requiresImprovementCount
, latestInadequateCount.ratingCount AS inadequateCount
FROM uniqLocalAuthorities
JOIN latestOutstandingCount ON uniqLocalAuthorities.localAuthority =latestOutstandingCount."Location Local Authority"
JOIN latestGoodCount ON uniqLocalAuthorities.localAuthority =latestGoodCount."Location Local Authority"
JOIN latestRequiresImprovementCount ON uniqLocalAuthorities.localAuthority =latestRequiresImprovementCount."Location Local Authority"
JOIN latestInadequateCount ON uniqLocalAuthorities.localAuthority =latestInadequateCount."Location Local Authority";
