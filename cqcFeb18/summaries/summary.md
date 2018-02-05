% summary of cqc inspection spreadsheet for Feb 2018
% Nick James
% 2018-02-05
 
----
 
## Extracts of [cqc data](https://www.cqc.org.uk)

NOTE generated DB too big for github, you'll have to recreate 
using clean.bat or an adaptation.

starting with [1 February 2018 Latest ratings.xlsx](https://www.cqc.org.uk/sites/default/files/1%20February%202018%20Latest%20ratings.xlsx)

Two sheets

+    1 - Active locations, by latest published rating
+    2 - Registered providers, by latest published rating

Source: CQC database as at 1 February 2018

have converted this to an sqlite database

not sure of active locations / registered providers split. is one a subset of the other?
have more or less normalised locations sheet but left providers alone. 
no foreign keys done.

have extracted counts of outstanding, good etc of overall judgements for all
locations by local authority, derived from locations table.
 
have also produced html and csv of brands -> locations and brands -> providers 
again derived from locations table so not comprehensive but a bit of an 
eye opener to me at least.

understanding this requires an understanding of the cqc's method of reporting.
I don't fully understand it and life's too short. basically there are various 
Services which are rated (ambulance, chemo etc) then an Overall service bunged in.
Then there are "Key Questions" which are things like Caring, Effective etc which 
also have an Overall bunged in. the rating is Outstanding, Good etc. any 
combination of "Service" and "Key Question" has a result in the "Outstanding" 
"Good" ... space. the result is a combinatorial explosion of limited value but 
there you go.

repo on github if you want the database / methodology. windows based I'm afraid 
and with dependencies...

have provided links to csvs should you want a spreadsheet. the branding ones will 
need to have row height opened right up in order to see deatils.

----

### Local authority ratings

have extracted counts of outstanding, good etc of overall judgements for all
locations by local authority. could do with computing as %age of total number 
of ratings for an easy comparison; can do if anyone that interested.

<iframe width="90%" src="cqcFeb18RatingByLA.html"></iframe>

[full size](cqcFeb18RatingByLA.html) <a href="cqcFeb18RatingByLA.csv" download="download" >csv</a>

----

all inadequate ratings showing brand, provider address

<iframe width="90%" src="inadequateReports.html"></iframe>

[full size](inadequateReports.html) <a href="inadequateReports.csv" download="download" >csv</a>

----

as above but with "Key Question" limited to Overall

<iframe width="90%" src="overallInadequateReports.html"></iframe>

[full size](overallInadequateReports.html) <a href="overallInadequateReports.csv" download="download" >csv</a>

----

health care brands and their locations from locations sheet

<iframe width="90%" src="groupedBrandsAndLocations.html"></iframe>

[full size](groupedBrandsAndLocations.html) <a href="groupedBrandsAndLocations.csv" download="download" >csv</a>

----

health care brands and their providers from locations sheet

<iframe width="90%" src="groupedBrandsAndProviders.html"></iframe>

[full size](groupedBrandsAndProviders.html) <a href="groupedBrandsAndProviders.csv" download="download" >csv</a>

----
