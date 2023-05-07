package ch.so.agi.sodata.stac;

import java.util.Properties;

import org.postgresql.PGProperty;

import ch.ehi.ili2db.base.Ili2db;
import ch.ehi.ili2db.base.Ili2dbException;
import ch.ehi.ili2db.gui.Config;
import ch.ehi.ili2pg.PgMain;

public class TestUtil {
    public static final String PG_CON_DDLUSER = "ddluser";
    public static final String PG_CON_DDLPASS = "ddluser";
    public static final String PG_CON_DMLUSER = "dmluser";
    public static final String PG_CON_DMLPASS = "dmluser";
    
    private static final String MODEL_NAME = "SO_AGI_STAC_20230426";
    private static final String MODEL_DIR = "src/main/resources/ili/";
    private static final String DB_SCHEMA = "agi_stac_v1";
    private static final String XTF_FILE = "src/test/resources/datasearch.xtf";
    
    public static void importXtf(String dburl) {
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
        
        Properties props = org.postgresql.Driver.parseURL(dburl, null);

        settings.setDbhost(props.getProperty(PGProperty.PG_HOST.getName()));
        settings.setDbport(props.getProperty(PGProperty.PG_PORT.getName()));
        settings.setDbdatabase(props.getProperty(PGProperty.PG_DBNAME.getName()));
        settings.setDbschema(DB_SCHEMA);
        settings.setDbusr(PG_CON_DDLUSER);
        settings.setDbpwd(PG_CON_DDLPASS);
        settings.setDburl(dburl);
        settings.setItfTransferfile(false);
        settings.setXtffile(XTF_FILE);
        
        try {
            Ili2db.run(settings, null);
        } catch (Ili2dbException e) {
            throw new RuntimeException(e.getMessage());        
        }
    }
}
