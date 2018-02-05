CREATE TABLE "locationsRaw"
 (
"Location ID" TEXT,
"Location Name" TEXT,
"Care Home?" TEXT,
"Location Type" TEXT,
"Location Primary Inspection Category" TEXT,
"Location Street Address" TEXT,
"Location Address Line 2" TEXT,
"Location City" TEXT,
"Location Post Code" TEXT,
"Location Local Authority" TEXT,
"Location Region" TEXT,
"Location ONSPD CCG Code" TEXT,
"Location ONSPD CCG" TEXT,
"Location Commissioning CCG Code" TEXT,
"Location Commissioning CCG Name" TEXT,
"Service / Population Group" TEXT,
"Key Question" TEXT,
"Latest Rating" TEXT,
"Publication Date" TEXT,
"Report Type" TEXT,
"URL" TEXT,
"Provider ID" TEXT,
"Provider Name" TEXT,
"Brand ID" TEXT,
"Brand Name" TEXT
);
CREATE TABLE "providersRaw"
 (
"Provider ID" TEXT,
"Provider Name" TEXT,
"Provider Type" TEXT,
"Provider Primary Inspection Category" TEXT,
"Provider Street Address" TEXT,
"Provider Address Line 2" TEXT,
"Provider City" TEXT,
"Provider Post Code" TEXT,
"Provider Local Authority" TEXT,
"Provider Region" TEXT,
"Service / Population Group" TEXT,
"Key Question" TEXT,
"Latest Rating" TEXT,
"Publication Date" TEXT,
"Report Type" TEXT,
"URL" TEXT,
"Brand ID" TEXT,
"Brand Name" TEXT
);
CREATE TABLE locationNameAddress(
  code TEXT,
  name TEXT,
  line1 TEXT,
  line2 TEXT,
  city TEXT,
  postCode TEXT
);
CREATE UNIQUE INDEX ndxLocationNameAddressCode
ON locationNameAddress (code);
CREATE INDEX ndxLocationNameAddressName
ON locationNameAddress (name);
CREATE INDEX ndxLocationNameAddressPostCode
ON locationNameAddress (postCode);
CREATE TABLE locationRegion(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxLocationRegionCode
ON locationRegion (code);
CREATE INDEX ndxLocationRegionName
ON locationRegion (name);
CREATE TABLE locationLocalAuthority(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxLocationLocalAuthorityCode
ON locationLocalAuthority (code);
CREATE INDEX ndxLocationLocalAuthorityName
ON locationLocalAuthority (name);
CREATE TABLE locationType(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxLocationTypeCode
ON locationType (code);
CREATE INDEX ndxLocationTypeName
ON locationType (name);
CREATE TABLE locationInspectionCategory(
  code TEXT,
  name TEXT
);
CREATE UNIQUE INDEX ndxLocationInspectionCategoryCode
ON locationInspectionCategory (code);
CREATE INDEX ndxLocationInspectionCategoryName
ON locationInspectionCategory (name);
CREATE TABLE locationsXproviders(
  locationCode TEXT,
  providerCode TEXT
);
CREATE UNIQUE INDEX ndxLocationsXprovidersLocation
ON locationsXproviders (locationCode);
CREATE INDEX ndxLocationsXprovidersProvider
ON locationsXproviders (providerCode);
CREATE TABLE commissioningCCGCode(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxCommissioningCCGCode
ON commissioningCCGCode (code);
CREATE INDEX ndxCommissioningCCGName
ON commissioningCCGCode (name);
CREATE TABLE ONSPDCCGCode(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxONSPDCCGCode
ON ONSPDCCGCode (code);
CREATE INDEX ndxONSPDCCGName
ON ONSPDCCGCode (name);
CREATE TABLE brands(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxBrandsCode
ON brands (code);
CREATE INDEX ndxBrandsName
ON brands (name);
CREATE TABLE providers(code TEXT,name TEXT);
CREATE UNIQUE INDEX ndxProvidersCode
ON providers (code);
CREATE INDEX ndxProvidersName
ON providers (name);
CREATE TABLE providersXbrands(
  providerCode TEXT,
  brandCode TEXT
);
CREATE UNIQUE INDEX ndxprovidersXbrandsProvider
ON providersXbrands (providerCode);
CREATE INDEX ndxprovidersXbrandsBrand
ON providersXbrands (brandCode);
CREATE VIEW "brandsAndProviders" AS 
SELECT DISTINCT
CASE WHEN brands.name GLOB 'BRAND*' THEN substr(brands.name, 7) ELSE brands.name END  AS brandName
,providers.name AS providerName
FROM brands
JOIN providersXbrands ON brands.code=providersXbrands.brandCode
JOIN providers ON providersXbrands.providerCode=providers.code
WHERE brands.name<>'-'
ORDER BY brandName;
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
CREATE VIEW "reportURL" AS 
SELECT DISTINCT
"code",
'http://www.cqc.org.uk/location/' || "code" AS "URL"
FROM "locationNameAddress";
CREATE TABLE services(code,name TEXT);
CREATE UNIQUE INDEX ndxServicesCode
ON services (code);
CREATE INDEX ndxServicesName
ON services (name);
CREATE TABLE locationReports(
  "Location ID" TEXT,
  "Publication Date" TEXT,
  serviceCode,
  "Key Question" TEXT,
  "Latest Rating" TEXT
);
CREATE INDEX ndxlocationReportsServicesCode
ON locationReports (serviceCode);
CREATE INDEX ndxServicesLocationID
ON locationReports ("Location ID");
CREATE TABLE locationIsCareHome(code TEXT,trueFalse);
CREATE UNIQUE INDEX ndxlocationIsCareHomeCode
ON locationIsCareHome (code);
CREATE INDEX ndxlocationIsCareHomeTF
ON locationIsCareHome (trueFalse);
CREATE TABLE locationONSPDCCGCode(
  locationCode TEXT,
  ONSCCGCode TEXT
);
CREATE UNIQUE INDEX ndxlocationONSPDCCGCodeLocationCode
ON locationONSPDCCGCode (locationCode);
CREATE INDEX ndxlocationONSPDCCGCodeONSCCG
ON locationONSPDCCGCode (ONSCCGCode);
CREATE TABLE locationCommissioningCCGCode(
  locationCode TEXT,
  commissioningCCGCode TEXT
);
CREATE UNIQUE INDEX ndxLocationCommissioningCCGCodeLocationCode
ON locationCommissioningCCGCode (locationCode);
CREATE INDEX ndxLocationCommissioningCCGCodeCommissioningCCGCode
ON locationCommissioningCCGCode (commissioningCCGCode);
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
CREATE VIEW "overallInadequateReports" 
AS
SELECT * FROM inadequateReports
WHERE "Key question"='Overall';
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
CREATE VIEW outstandingLA 
AS 
SELECT localAuthority, ratingCount AS outstandingCount FROM allLocalAuthorityRatings WHERE latestRating='Outstanding';
CREATE VIEW goodLA 
AS 
SELECT localAuthority, ratingCount AS goodCount FROM allLocalAuthorityRatings WHERE latestRating='Good';
CREATE VIEW requiresImprovementLA 
AS 
SELECT localAuthority, ratingCount AS requiresImprovementCount FROM allLocalAuthorityRatings WHERE latestRating='Requires improvement';
CREATE VIEW inadequateLA 
AS 
SELECT localAuthority, ratingCount AS inadequateCount FROM allLocalAuthorityRatings WHERE latestRating='Inadequate';
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
