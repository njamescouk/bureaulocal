BEGIN TRANSACTION;

DROP TABLE IF EXISTS locationNameAddress;

CREATE TABLE locationNameAddress
AS
SELECT DISTINCT
"Location ID" AS code,
"Location Name" AS name,
"Location Street Address" AS line1,
"Location Address Line 2" AS line2,
"Location City" AS city,
"Location Post Code" AS postCode
FROM "locationsRaw"
ORDER BY code,name,postCode;

DROP INDEX IF EXISTS ndxLocationNameAddressCode;
CREATE UNIQUE INDEX ndxLocationNameAddressCode
ON locationNameAddress (code);

DROP INDEX IF EXISTS ndxLocationNameAddressName;
CREATE INDEX ndxLocationNameAddressName
ON locationNameAddress (name);

DROP INDEX IF EXISTS ndxLocationNameAddressPostCode;
CREATE INDEX ndxLocationNameAddressPostCode
ON locationNameAddress (postCode);
----------------------------------------------------------


DROP TABLE IF EXISTS locationRegion;

CREATE TABLE locationRegion
AS
SELECT DISTINCT
"Location ID" AS code,
"Location Region" AS name
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxLocationRegionCode;
CREATE UNIQUE INDEX ndxLocationRegionCode
ON locationRegion (code);

DROP INDEX IF EXISTS ndxLocationRegionName;
CREATE INDEX ndxLocationRegionName
ON locationRegion (name);
----------------------------------------------------------

DROP TABLE IF EXISTS locationLocalAuthority;

CREATE TABLE locationLocalAuthority
AS
SELECT DISTINCT
"Location ID" AS code,
"Location Local Authority" AS name
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxLocationLocalAuthorityCode;
CREATE UNIQUE INDEX ndxLocationLocalAuthorityCode
ON locationLocalAuthority (code);

DROP INDEX IF EXISTS ndxLocationLocalAuthorityName;
CREATE INDEX ndxLocationLocalAuthorityName
ON locationLocalAuthority (name);
----------------------------------------------------------

DROP TABLE IF EXISTS locationType;

CREATE TABLE locationType
AS
SELECT DISTINCT
"Location ID" AS code,
"Location Type" AS name
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxLocationTypeCode;
CREATE UNIQUE INDEX ndxLocationTypeCode
ON locationType (code);

DROP INDEX IF EXISTS ndxLocationTypeName;
CREATE INDEX ndxLocationTypeName
ON locationType (name);
----------------------------------------------------------

DROP TABLE IF EXISTS locationInspectionCategory;

CREATE TABLE locationInspectionCategory
AS
SELECT DISTINCT
"Location ID" AS code,
"Location Primary Inspection Category" AS name
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxLocationInspectionCategoryCode;
CREATE UNIQUE INDEX ndxLocationInspectionCategoryCode
ON locationInspectionCategory (code);

DROP INDEX IF EXISTS ndxLocationInspectionCategoryName;
CREATE INDEX ndxLocationInspectionCategoryName
ON locationInspectionCategory (name);
----------------------------------------------------------

DROP TABLE IF EXISTS locationsXproviders;

CREATE TABLE "locationsXproviders" AS 
SELECT DISTINCT
"Location ID" AS locationCode,
"Provider ID" AS providerCode
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxLocationsXprovidersLocation;
CREATE UNIQUE INDEX ndxLocationsXprovidersLocation
ON locationsXproviders (locationCode);

DROP INDEX IF EXISTS ndxLocationsXprovidersProvider;
CREATE INDEX ndxLocationsXprovidersProvider
ON locationsXproviders (providerCode);
----------------------------------------------------------

DROP TABLE IF EXISTS commissioningCCGCode;

CREATE TABLE commissioningCCGCode
AS
SELECT DISTINCT
"Location Commissioning CCG Code" AS code,
"Location Commissioning CCG Name" AS name
FROM "locationsRaw"
WHERE "Location Commissioning CCG Code" <> ''
ORDER BY code;

DROP INDEX IF EXISTS ndxCommissioningCCGCode;
CREATE UNIQUE INDEX ndxCommissioningCCGCode
ON commissioningCCGCode (code);

DROP INDEX IF EXISTS ndxCommissioningCCGName;
CREATE INDEX ndxCommissioningCCGName
ON commissioningCCGCode (name);
----------------------------------------------------------

DROP TABLE IF EXISTS ONSPDCCGCode;

CREATE TABLE ONSPDCCGCode
AS
SELECT DISTINCT
"Location ONSPD CCG Code" AS code,
"Location ONSPD CCG" AS name
FROM "locationsRaw"
WHERE "Location ONSPD CCG Code" <> ''
ORDER BY code;

DROP INDEX IF EXISTS ndxONSPDCCGCode;
CREATE UNIQUE INDEX ndxONSPDCCGCode
ON ONSPDCCGCode (code);

DROP INDEX IF EXISTS ndxONSPDCCGName;
CREATE INDEX ndxONSPDCCGName
ON ONSPDCCGCode (name);
----------------------------------------------------------

DROP TABLE IF EXISTS brands;

CREATE TABLE brands
AS
SELECT DISTINCT
"Brand ID" AS code,
"Brand Name" AS name
FROM "locationsRaw"
ORDER BY code;

DROP INDEX IF EXISTS ndxBrandsCode;
CREATE UNIQUE INDEX ndxBrandsCode
ON brands (code);

DROP INDEX IF EXISTS ndxBrandsName;
CREATE INDEX ndxBrandsName
ON brands (name);
----------------------------------------------------------

DROP TABLE IF EXISTS providers;

CREATE TABLE providers
AS
SELECT DISTINCT
"Provider ID" AS code,
"Provider Name" AS name
FROM "locationsRaw"
ORDER BY code;

DROP INDEX IF EXISTS ndxProvidersCode;
CREATE UNIQUE INDEX ndxProvidersCode
ON providers (code);

DROP INDEX IF EXISTS ndxProvidersName;
CREATE INDEX ndxProvidersName
ON providers (name);
----------------------------------------------------------

DROP TABLE IF EXISTS providersXbrands;

CREATE TABLE providersXbrands
AS
SELECT DISTINCT
"Provider ID" AS providerCode,
"Brand ID" AS brandCode
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxprovidersXbrandsProvider;
CREATE UNIQUE INDEX ndxprovidersXbrandsProvider
ON providersXbrands (providerCode);

DROP INDEX IF EXISTS ndxprovidersXbrandsBrand;
CREATE INDEX ndxprovidersXbrandsBrand
ON providersXbrands (brandCode);
----------------------------------------------------------

DROP VIEW IF EXISTS brandsAndProviders;

CREATE VIEW "brandsAndProviders" AS 
SELECT DISTINCT
CASE WHEN brands.name GLOB 'BRAND*' THEN substr(brands.name, 7) ELSE brands.name END  AS brandName
,providers.name AS providerName
FROM brands
JOIN providersXbrands ON brands.code=providersXbrands.brandCode
JOIN providers ON providersXbrands.providerCode=providers.code
WHERE brands.name<>'-'
ORDER BY brandName;
----------------------------------------------------------

DROP VIEW IF EXISTS groupedBrandsAndProviders;

CREATE VIEW "groupedBrandsAndProviders" AS 
SELECT DISTINCT
COUNT(providerName) AS numberOfProviders
,brandName
,group_concat(providerName, '
') AS providers
FROM brandsAndProviders
GROUP BY brandName
HAVING numberOfProviders>1
ORDER BY numberOfProviders DESC, brandName;
----------------------------------------------------------

DROP VIEW IF EXISTS "reportURL";

/* NOTE this may not be true for all time */
CREATE VIEW "reportURL" AS 
SELECT DISTINCT
"code",
'http://www.cqc.org.uk/location/' || "code" AS "URL"
FROM "locationNameAddress";
----------------------------------------------------------

DROP TABLE IF EXISTS services;

CREATE TABLE services
AS
SELECT DISTINCT
min("ROWID") AS code, /* fake a unique id. will not be true for all time... */
"Service / Population Group" AS name
FROM "locationsRaw"
GROUP BY name
ORDER BY "Service / Population Group";

DROP INDEX IF EXISTS ndxServicesCode;
CREATE UNIQUE INDEX ndxServicesCode
ON services (code);

DROP INDEX IF EXISTS ndxServicesName;
CREATE INDEX ndxServicesName
ON services (name);
----------------------------------------------------------

DROP TABLE IF EXISTS locationReports;

CREATE TABLE locationReports
AS
SELECT DISTINCT
"Location ID",
"Publication Date",
services.code AS serviceCode,
"Key Question",
"Latest Rating"
FROM "locationsRaw"
JOIN services ON services.name="Service / Population Group"
ORDER BY "Location ID",
"Publication Date",
"Service / Population Group",
"Key Question";

DROP INDEX IF EXISTS ndxlocationReportsServicesCode;
CREATE INDEX ndxlocationReportsServicesCode
ON locationReports (serviceCode);

DROP INDEX IF EXISTS ndxServicesLocationID;
CREATE INDEX ndxServicesLocationID
ON locationReports ("Location ID");
----------------------------------------------------------

DROP TABLE IF EXISTS locationIsCareHome;

CREATE TABLE locationIsCareHome
AS
SELECT DISTINCT
"Location ID" AS code,
CASE "Care Home?" WHEN 'Y' THEN 1 ELSE 0 END AS trueFalse
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxlocationIsCareHomeCode;
CREATE UNIQUE INDEX ndxlocationIsCareHomeCode
ON locationIsCareHome (code);

DROP INDEX IF EXISTS ndxlocationIsCareHomeTF;
CREATE INDEX ndxlocationIsCareHomeTF
ON locationIsCareHome (trueFalse);
----------------------------------------------------------

DROP TABLE IF EXISTS locationONSPDCCGCode;

CREATE TABLE locationONSPDCCGCode
AS
SELECT DISTINCT
"Location ID" AS locationCode,
"Location ONSPD CCG Code" AS ONSCCGCode
FROM "locationsRaw";

DROP INDEX IF EXISTS ndxlocationONSPDCCGCodeLocationCode;
CREATE UNIQUE INDEX ndxlocationONSPDCCGCodeLocationCode
ON locationONSPDCCGCode (locationCode);

DROP INDEX IF EXISTS ndxlocationONSPDCCGCodeONSCCG;
CREATE INDEX ndxlocationONSPDCCGCodeONSCCG
ON locationONSPDCCGCode (ONSCCGCode);
----------------------------------------------------------

DROP TABLE IF EXISTS locationCommissioningCCGCode;

CREATE TABLE locationCommissioningCCGCode
AS
SELECT DISTINCT
"Location ID" AS locationCode,
"Location Commissioning CCG Code" AS commissioningCCGCode
FROM "locationsRaw"
WHERE CommissioningCCGCode<>'';

DROP INDEX IF EXISTS ndxLocationCommissioningCCGCodeLocationCode;
CREATE UNIQUE INDEX ndxLocationCommissioningCCGCodeLocationCode
ON locationCommissioningCCGCode (locationCode);

DROP INDEX IF EXISTS ndxLocationCommissioningCCGCodeCommissioningCCGCode;
CREATE INDEX ndxLocationCommissioningCCGCodeCommissioningCCGCode
ON locationCommissioningCCGCode (commissioningCCGCode);
----------------------------------------------------------

DROP VIEW IF EXISTS"groupedBrandsAndLocations";

CREATE VIEW "groupedBrandsAndLocations" AS 
SELECT DISTINCT
COUNT(brands.name) AS "numberOfLocations"
,CASE WHEN brands.name GLOB 'BRAND*' THEN substr(brands.name, 7) ELSE brands.name END  AS brandName
/*
,group_concat(providers.name,'
') AS providerNames
*/
,group_concat(locationNameAddress.name,'
') AS locationNames
FROM brands
JOIN providersXbrands ON brands.code=providersXbrands.brandCode
JOIN providers ON providersXbrands.providerCode=providers.code
JOIN locationsXproviders ON locationsXproviders.providerCode=providers.code
JOIN locationNameAddress ON locationsXproviders.locationCode=locationNameAddress.code
WHERE brands.name<>'-'
GROUP BY brandName
ORDER BY numberOfLocations DESC;
----------------------------------------------------------

/* 
really need to pick out most recent report from locationReports

However
    SELECT 
    CASE 
    WHEN MAX("Publication Date") <> MIN("Publication Date") 
    THEN 'multiple dates for "Location ID", "Publication Date", serviceCode, "Key Question"' 
    ELSE 'Latest OK' END AS status,
     * 
    FROM locationReports
    GROUP BY "Location ID" ,
      "Publication Date" ,
      serviceCode,
      "Key Question" 
    ORDER BY status, "Publication Date";

seems to indicate we only have latest publication dates anyway
*/

DROP VIEW IF EXISTS "inadequateReports";

CREATE VIEW "inadequateReports" 
AS 
SELECT DISTINCT
CASE WHEN brands.name GLOB 'BRAND*' THEN substr(brands.name, 7) ELSE brands.name END  AS brandName
,providers.name AS providerName
,locationNameAddress.name AS locationName
,locationNameAddress.line1
,locationNameAddress."postCode"
,locationReports."Publication Date"
,services.name AS serviceName
,locationReports."Key Question"
,locationReports."Latest Rating"
FROM locationReports
JOIN locationsXproviders ON locationsXproviders.locationCode=locationReports."Location ID"
JOIN locationNameAddress ON "locationsXproviders".locationCode=locationNameAddress.code
JOIN providersXbrands USING (providerCode)
JOIN brands ON brands.code=providersXbrands.brandCode
JOIN services ON services.code=locationReports.serviceCode
JOIN providers ON providers.code=locationsXproviders.providerCode
WHERE "Latest Rating"='Inadequate'
ORDER BY brandName, providerName, locationName;
----------------------------------------------------------

DROP VIEW IF EXISTS "overallInadequateReports";

CREATE VIEW "overallInadequateReports" 
AS
SELECT * FROM inadequateReports
WHERE "Key question"='Overall';
----------------------------------------------------------

DROP VIEW IF EXISTS "allLocalAuthorityRatings";

CREATE VIEW "allLocalAuthorityRatings" AS 
SELECT 
locationLocalAuthority.name AS localAuthority,
locationReports."Latest Rating" AS latestRating,
COUNT(locationReports."Latest Rating") AS ratingCount
FROM locationLocalAuthority 
JOIN locationReports ON locationLocalAuthority.code=locationReports."Location ID"
WHERE locationReports."Key Question"='Overall'
AND locationReports.serviceCode=1 -- Overall
GROUP BY locationLocalAuthority.name, locationReports."Latest Rating";

DROP VIEW IF EXISTS outstandingLA;
CREATE VIEW outstandingLA 
AS 
SELECT localAuthority, ratingCount AS outstandingCount FROM allLocalAuthorityRatings WHERE latestRating='Outstanding';

DROP VIEW IF EXISTS goodLA;
CREATE VIEW goodLA 
AS 
SELECT localAuthority, ratingCount AS goodCount FROM allLocalAuthorityRatings WHERE latestRating='Good';

DROP VIEW IF EXISTS requiresImprovementLA;
CREATE VIEW requiresImprovementLA 
AS 
SELECT localAuthority, ratingCount AS requiresImprovementCount FROM allLocalAuthorityRatings WHERE latestRating='Requires improvement';

DROP VIEW IF EXISTS inadequateLA;
CREATE VIEW inadequateLA 
AS 
SELECT localAuthority, ratingCount AS inadequateCount FROM allLocalAuthorityRatings WHERE latestRating='Inadequate';


DROP VIEW IF EXISTS localAuthorityRatings;
CREATE VIEW localAuthorityRatings AS 
SELECT DISTINCT
locationLocalAuthority.name AS localAuthority
,outstandingLA.outstandingCount
,goodLA.goodCount
,requiresImprovementLA.requiresImprovementCount
,inadequateLA.inadequateCount
FROM locationLocalAuthority
JOIN outstandingLA ON locationLocalAuthority.name=outstandingLA.localAuthority
JOIN goodLA ON locationLocalAuthority.name=goodLA.localAuthority
JOIN requiresImprovementLA ON locationLocalAuthority.name=requiresImprovementLA.localAuthority
JOIN inadequateLA ON locationLocalAuthority.name=inadequateLA.localAuthority
ORDER BY locationLocalAuthority.name;



----------------------------------------------------------

COMMIT;
--DROP TABLE "locationsRaw"; -- we're finished
--VACUUM;

/*
Mega join if needed

SELECT locationNameAddress.code AS "Location ID",
locationNameAddress.name AS "Location Name",  
CASE WHEN locationIsCareHome.trueFalse THEN 'Y' ELSE 'N' END AS "Care Home?",
locationType.name AS "Location Type",
locationInspectionCategory.name AS "Location Primary Inspection Category",
locationNameAddress.line1 AS "Location Street Address",
locationNameAddress.line2 AS "Location Address Line 2",
locationNameAddress.city AS "Location City",
locationNameAddress.postCode AS "Location Post Code",
locationLocalAuthority.name AS "Location Local Authority",
locationRegion.name AS "Location Region",
locationONSPDCCGCode.ONSCCGCode AS "Location ONSPD CCG Code",
ONSPDCCGCode.name AS "Location ONSPD CCG",
locationCommissioningCCGCode."commissioningCCGCode" AS "Location Commissioning CCG Code",
commissioningCCGCode.name AS "Location Commissioning CCG Name",
services.name AS "Service / Population Group",
locationReports."Key Question",
locationReports."Latest Rating",
locationReports."Publication Date",
'Location' AS "Report Type",
reportURL.URL,
providers.code AS "Provider ID",
providers.name AS "Provider Name",
brands.code AS "Brand ID",
brands.name AS "Brand Name"
FROM locationNameAddress
JOIN locationIsCareHome ON locationNameAddress.code=locationIsCareHome.code
JOIN locationType ON locationNameAddress.code=locationType.code
JOIN locationInspectionCategory ON locationNameAddress.code=locationInspectionCategory.code
JOIN locationLocalAuthority ON locationNameAddress.code=locationLocalAuthority.code
JOIN locationRegion ON locationNameAddress.code=locationRegion.code
JOIN locationONSPDCCGCode ON locationONSPDCCGCode.locationCode=locationNameAddress.code
JOIN ONSPDCCGCode ON ONSPDCCGCode.code=locationONSPDCCGCode.ONSCCGCode
JOIN locationCommissioningCCGCode ON locationNameAddress.code=locationCommissioningCCGCode.locationCode
JOIN commissioningCCGCode ON locationCommissioningCCGCode.commissioningCCGCode=commissioningCCGCode.code
JOIN locationReports ON locationNameAddress.code=locationReports."Location ID"
JOIN services ON services.code=locationReports.serviceCode
JOIN reportURL ON locationNameAddress.code=reportURL.code
JOIN locationsXproviders ON locationNameAddress.code=locationsXproviders.locationCode
JOIN providers ON locationsXproviders.providerCode=providers.code
JOIN providersXbrands ON locationsXproviders.providerCode=providersXbrands.providerCode
JOIN brands ON providersXbrands.brandCode=brands.code
;

*/