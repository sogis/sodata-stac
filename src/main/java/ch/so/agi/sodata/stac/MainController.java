package ch.so.agi.sodata.stac;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
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

import ch.so.agi.sodata.stac.util.Util;

@RestController
public class MainController {
    private Logger log = LoggerFactory.getLogger(this.getClass());

    @Autowired
    JdbcTemplate jdbcTemplate;

    @Autowired
    NamedParameterJdbcTemplate jdbcParamTemplate;

    @GetMapping(value = "/catalog.json", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getCatalog() {
        
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("host", getHost());
        
        String sql = Util.loadUtf8("sql/catalog.sql");
        
        String foo = jdbcParamTemplate.queryForObject(sql, parameters, String.class); 

        
//        String foo = jdbcTemplate.queryForObject(sql, String.class);  .query("SELECT identifier FROM agi_stac_v1.collection", new RowMapper<String>() {
//            @Override
//            public String mapRow(ResultSet rs, int rowNum) throws SQLException {
//                String identifier = rs.getString(1);
//                return identifier;
//            }
//            
//        });
       
        return new ResponseEntity<String>(foo, HttpStatus.OK);
    }

    @GetMapping(value = "/{collectionId}/collection.json", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getCollection(@PathVariable String collectionId) {

        
        return new ResponseEntity<String>(collectionId, HttpStatus.OK);
    }
    
    
    private String getHost() {
        return ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
    }    
}
