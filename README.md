# sodata-stac

```
java -jar /Users/stefan/apps/SaxonHE10-6J/saxon-he-10.6.jar -s:src/test/resources/datasearch.xml -xsl:src/main/resources/xsl/xml2xtf.xsl -o:fubar.xtf

java -jar /Users/stefan/apps/ilivalidator-1.13.3/ilivalidator-1.13.3.jar --modeldir src/main/resources/ili fubar.xtf

java -jar /Users/stefan/apps/ili2pg-4.9.1/ili2pg-4.9.1.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --modeldir src/main/resources/ili --models SO_AGI_STAC_20230426 --dbschema agi_stac1 --doSchemaImport --import fubar.xtf

java -jar /Users/stefan/apps/ili2pg-4.9.1/ili2pg-4.9.1.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --modeldir src/main/resources/ili --models SO_AGI_STAC_20230426 --dbschema agi_stac1 --doSchemaImport --import fubar.xtf

java -jar /Users/stefan/apps/ili2pg-4.9.1/ili2pg-4.9.1.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --modeldir src/main/resources/ili --models SO_AGI_STAC_20230426 --dbschema agi_stac2 --doSchemaImport --coalesceJson --import fubar.xtf
```