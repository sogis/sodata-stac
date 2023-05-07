package ch.so.agi.sodata.stac;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.fasterxml.jackson.databind.ObjectMapper;

import ch.so.agi.sodata.stac.util.Util;
import jakarta.annotation.PostConstruct;

@RestController
public class MainController {
    private Logger log = LoggerFactory.getLogger(this.getClass());

    @Value("${app.dbSchema}")
    private String dbSchema;
    
//    @Autowired
//    JdbcTemplate jdbcTemplate;

    @Autowired
    NamedParameterJdbcTemplate jdbcParamTemplate;

    private String stmtCatalog;
    private String stmtCollection;
    private String stmtItem;
    
    @PostConstruct
    private void init() {
        // Das NamedParameterJdbcTemplate stolpert über die Kombination ":dbSchema.collection"
        // (also Schemanamen und Tabellennamen). Es versucht den kompletten String zu ersetzen.
        // Aus diesem Grund tausche ich das Schema bereits hier aus.
        // (In dbeaver funktioniert es, btw).
        stmtCatalog = Util.loadUtf8("sql/catalog.sql").replaceAll(":dbSchema", dbSchema);
        stmtCollection = Util.loadUtf8("sql/collection.sql").replaceAll(":dbSchema", dbSchema);
        stmtItem = Util.loadUtf8("sql/item.sql").replaceAll(":dbSchema", dbSchema);
    }
    
    @GetMapping(value = "/catalog.json", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getCatalog() {
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("host", getHost());
                
        String json = jdbcParamTemplate.queryForObject(stmtCatalog, parameters, String.class); 
        return new ResponseEntity<String>(json, HttpStatus.OK);                
    }

    @GetMapping(value = "/{collectionId}/collection.json", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getCollection(@PathVariable String collectionId) {
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("host", getHost());
        parameters.addValue("id", collectionId);
        
        String json = jdbcParamTemplate.queryForObject(stmtCollection, parameters, String.class); 
        return new ResponseEntity<String>(json, HttpStatus.OK);
    }
     
    @GetMapping(value = "/{collectionId}/{itemId}/{itemId}.json", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getItem(@PathVariable String collectionId, @PathVariable String itemId) {
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("host", getHost());
        parameters.addValue("id", itemId);
        parameters.addValue("collectionId", collectionId);
    
        String json = jdbcParamTemplate.queryForObject(stmtItem, parameters, String.class); 
        return new ResponseEntity<String>(json, HttpStatus.OK);
    }
        
    private String getHost() {
        return ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
    }    
}
