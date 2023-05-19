# sodata-stac

## Todo
- Sinnvolle Index setzen in DB (falls nötig)
- HTML in z.B. Description mit CommonMark
- BoundingBox Range anpassen in Datenmodell
- Modell aus diesem Repo entfernen und in die Ablage kopieren.
- XSL: Wo ist Master? Eventuell sinnvoll hier?
- Caching der Requests (da sie sich nur einmal pro Tag ändern)

## Beschreibung

Das Repository verwaltet den Quellcode der Herstellung und Bereitstellung des STAC-Kataloges der Geodaten. Die dynamische STAC-API-Spezifikation ist (noch?) nicht unterstützt. D.h. es sind keine Queries möglich, sondern es wird ein statischer Katalog mit Collections publiziert.

## Komponenten

_sodata-stac_ besteht aus der vorliegenden Komponente in Form einer Spring Boot Anwendung. Sie wiederum ist Bestandteil der funktionalen Einheit [Datenbezug](https://github.com/sogis/dok/blob/dok/dok_funktionale_einheiten/Documents/Datenbezug/Datenbezug.md). Die Daten müssen einem Datenmodell entsprechend in einer PostgreSQL-Datenbank vorliegen. Die Umwandlung der Datensuche-XML-Datei in eine INTERLIS-Transferdatei wird mit XSLT in einem [GRETL-Job](https://github.com/sogis/gretljobs/tree/main/agi_stac) gemacht. Im gleichen Job werden die Daten in die Datenbank importiert.

## Konfigurieren und Starten

Wird die Anwendung mittels Docker gestartet, kann sie mittels Env-Variablen gesteuert werden. Ohne Docker müssen die normalen Spring Boot Konfigurationsmöglichen verwendet werden (siehe unten).
Die Anwendung kann am einfachsten mittels Env-Variablen gesteuert werden. Es stehen aber auch die normalen Spring Boot Konfigurationsmöglichkeiten zur Verfügung (siehe "Externalized Configuration"). Die Tomcat-Standardwerte gelten nur wenn die Anwendung mittels Docker verwendet wird. Sonst gelten die Standardwerten von Spring Boot resp. Tomcat.

| Name (Env / Spring Boot) | Beschreibung | Standard |
|-----|-----|-----|
| `DBURL` / `--spring.datasource.url` | JDBC-Url | |
| `DBUSR` / `--spring.datasource.username` | Datenbank-Benutzer | |
| `DBPWD` / `--spring.datasource.password` | Datenbank-Passwort | |
| `DBSCHEMA` / `--app.dbSchema` | Datenbank-Schema | `agi_stac_v1` |
| `TOMCAT_THREADS_MAX` / `--server.tomcat.threads.max` | Maximale Anzahl Threads, welche die Anwendung gleichzeitig bearbeitet. | `20` |
| `TOMCAT_ACCEPT_COUNT` / `--server.tomcat.accept-count` | Maximale Grösser der Queue, falls keine Threads mehr verfügbar. | `100` |
| `TOMCAT_MAX_CONNECTIONS` / `--server.tomcat.max-connections` | Maximale Threads des Servers. | `500` |
| `HIKARI_MAX_POOL_SIZE` /  `--spring.datasource.hikari.maximum-pool-size` | Grösse des DB-Connections-Pools | `10` |

Die Tomcat-Optionen sind sehr vereinfacht wiedergegeben. Auch weil im Detail relativ kompliziert. Siehe dazu:

- https://www.datadoghq.com/blog/tomcat-architecture-and-performance/
- https://stackoverflow.com/questions/39002090/spring-boot-limit-on-number-of-connections-created

### Java

```
java -jar build/libs/sodata-stac-0.0.LOCALBUILD-exec.jar \
--spring.datasource.url=jdbc:postgresql://localhost:54321/edit \
--spring.datasource.username=ddluser \
--spring.datasource.password=ddluser \
--app.dbSchema=agi_stac_v1
```

### Docker

```
docker run -p8080:8080 -e DBURL=jdbc:postgresql://localhost:54321/edit -e DBUSR=ddluser -e DBPWD=ddluser -e DBSCHEMA=agi_stac_v1 sogis/sodata-stac:latest
```

Resp. `jdbc:postgresql://host.docker.internal:54321/edit` unter macOS.

## Externe Abhängigkeiten

Datenbank mit publizierten Datenthemen (abgeleitet aus Datensuche-XML).

## Konfiguration und Betrieb in der GDI

@Michael: todo

## Interne Struktur

Die Businesslogik in der Spring Boot Anwendung ist sehr gering. Es werden praktisch nur ein paar wenige Controller verwendet. Die Hauptlogik wird mit SQL gemacht. Siehe dazu die SQL-Dateien. Zur Zeit sind gewisse Abkürzungen vorhanden: so wären mehrere Boundingboxen möglich für eine Collection. Die Query ist aber darauf ausgelegt, dass es nur eine gibt.

Sowieso ist die Anwendung natürlich sehr stark an das Datenmodell gekoppelt, welches wiederum nicht sämtliche Freiheiten der STAC-Spezifikation zulässt. Die Anwendung und das Modell gehen von einem Katalog mit einer beliebigen Anzahl Collections aus. 

Damit der STAC-Katalog auch von Webanwendungen verwendet werden kann, musste CORS korrekt konfiguriert werden.

Weil für die lokale Entwicklung mit dem docker-compose-Support von Spring Boot und Testcontainers gearbeitet wird, kann (m.E.) nicht alles mit den application.properties-Dateien konfiguriert werden, da sonst z.B. die DB-Verbindungen wieder überschrieben würden, die beim Testen und Entwickeln automatisch konfiguriert werden. Aus diesem Grund werden für den Betrieb insb. die DB-Konfigurationen von aussen gesteuert. Siehe dazu v.a. das Dockerfile.

Das Native Image kann ich zur Zeit nicht herstellen. Irgendwie scheint AOT mit Testcontainers Probleme zu haben (so jedenfalls die Warnung). Und das kompilierte Binary findet die init-Methode des MainControllers nicht (auch wenn mit Agent die Konfigdateien hergestellt wurden).

## Entwicklung

### Run 

Damit die DevApplication-Klasse im test-Ordner gefunden wird, darf in Eclipse unter `Run Configurations` - `Classpath` der test-Ordner _nicht_ exkludiert werden.

Es muss `-Dspring.profiles.active=dev` als Argument gesetzt werden. Es muss verhindert werden, dass beim Ausführen der Tests (also mit `./gradle clean tests`) die "DevApplication"-Klasse ignoriert wird. Sonst kann der Kontext nicht initialisert werden.


### Build

```
./gradlew clean build
```

```
docker build -t sogis/sodata-stac:latest -f Dockerfile.jvm .
```

### XSLT 

```
java -jar /Users/stefan/apps/SaxonHE10-6J/saxon-he-10.6.jar -s:src/test/resources/datasearch.xml -xsl:src/main/resources/xsl/xml2xtf.xsl -o:src/test/resources/datasearch.xtf

java -jar /Users/stefan/apps/ilivalidator-1.13.3/ilivalidator-1.13.3.jar --modeldir src/main/resources/ili src/test/resources/datasearch.xtf
```

Import wird während der Entwicklung und des Testens im Code selber gemacht. Hier der Vollständigkeit halber:

```
java -jar /Users/stefan/apps/ili2pg-4.9.1/ili2pg-4.9.1.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --modeldir src/main/resources/ili --models SO_AGI_STAC_20230426 --dbschema agi_stac_v1 --disableValidation --doSchemaImport --coalesceJson --importBatchSize 5000 --import src/test/resources/datasearch.xtf

java -jar /Users/stefan/apps/ili2pg-4.9.1/ili2pg-4.9.1.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr ddluser --dbpwd ddluser --modeldir src/main/resources/ili --models SO_AGI_STAC_20230426 --dbschema agi_stac_v1 --disableValidation  --importBatchSize 5000 --import src/test/resources/datasearch.xtf
```
