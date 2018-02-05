@echo off
for %%t in (groupedBrandsAndProviders groupedBrandsAndLocations inadequateReports overallInadequateReports) do call :makeHtml %%t

sqlite3 -header -csv cqcFeb18.db "SELECT * FROM localAuthorityRatings;" | csvRewrite -css summaries.css -s > summaries\cqcFeb15RatingByLA.html
sqlite3 -header -csv cqcFeb18.db "SELECT * FROM localAuthorityRatings;" | csvRewrite > summaries\cqcFeb15RatingByLA.csv

pushd summaries
pandoc -c summaries.css -s -o index.html -f markdown -t html5 summary.md
popd

goto :eof

:makeHtml
sqlite3 -header -csv cqcFeb18.db "SELECT * FROM %1;" | csvRewrite -css summaries.css -s > summaries\%1.html
sqlite3 -header -csv cqcFeb18.db "SELECT * FROM %1;" > summaries\%1.csv

goto :eof
