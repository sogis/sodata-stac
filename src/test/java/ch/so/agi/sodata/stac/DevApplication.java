package ch.so.agi.sodata.stac;

import java.util.Properties;

import org.postgresql.PGProperty;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.jdbc.JdbcConnectionDetails;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import ch.ehi.ili2db.base.Ili2db;
import ch.ehi.ili2db.base.Ili2dbException;
import ch.ehi.ili2db.gui.Config;
import ch.ehi.ili2pg.PgMain;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Configuration
@ConditionalOnProperty(
        name = "spring.profiles.active",
        havingValue = "dev",
        matchIfMissing = false)
public class DevApplication {
    private Logger logger = LoggerFactory.getLogger(this.getClass());

    private static final String MODEL_NAME = "SO_AGI_STAC_20230426";
    private static final String MODEL_DIR = "src/main/resources/ili/";
    private static final String DB_SCHEMA = "agi_stac_v1";
    private static final String DB_USR = "ddluser";
    private static final String DB_PWD = "ddluser";
    private static final String XTF_FILE = "src/test/resources/datasearch.xtf";
    
    public static void main(String[] args) {
        SpringApplication.from(Application::main).run(args);
    }
    
    @Bean
    CommandLineRunner devInit(JdbcConnectionDetails postgres) {
        return args -> {
            Config settings = new Config();
            new PgMain().initConfig(settings);
            settings.setFunction(Config.FC_IMPORT);
            settings.setModels(MODEL_NAME);
            settings.setModeldir(MODEL_DIR);
            settings.setDoImplicitSchemaImport(true);
            settings.setValidation(false);
            settings.setJsonTrafo(Config.JSON_TRAFO_COALESCE);
            settings.setDeleteMode(Config.DELETE_DATA);
            settings.setBatchSize(5000);
            
            Properties props = org.postgresql.Driver.parseURL(postgres.getJdbcUrl(), null);

            settings.setDbhost(props.getProperty(PGProperty.PG_HOST.getName()));
            settings.setDbport(props.getProperty(PGProperty.PG_PORT.getName()));
            settings.setDbdatabase(props.getProperty(PGProperty.PG_DBNAME.getName()));
            settings.setDbschema(DB_SCHEMA);
            settings.setDbusr(DB_USR);
            settings.setDbpwd(DB_PWD);
            settings.setDburl(postgres.getJdbcUrl());
            settings.setItfTransferfile(false);
            settings.setXtffile(XTF_FILE);
            
            try {
                Ili2db.run(settings, null);
            } catch (Ili2dbException e) {
                logger.warn(e.getMessage());
            }
        };
    }

}
