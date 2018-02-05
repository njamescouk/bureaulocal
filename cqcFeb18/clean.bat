goto skipImport
:skipImport
if exist cqcFeb18.db del cqcFeb18.db
copy locations.csv locationsRaw.csv
copy providers.csv providersRaw.csv
sqliteimport cqcFeb18.db locationsRaw.csv
sqliteimport cqcFeb18.db providersRaw.csv
del locationsRaw.csv
del providersRaw.csv

sqlite3 cqcFeb18.db < clean.sql
