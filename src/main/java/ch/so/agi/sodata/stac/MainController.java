package ch.so.agi.sodata.stac;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MainController {
    private Logger log = LoggerFactory.getLogger(this.getClass());

    @Autowired
    JdbcTemplate jdbcTemplate;

    @GetMapping("/catalog.json")
    public ResponseEntity<?> getCatalog() {
        
        List<String> foo = jdbcTemplate.query("SELECT identifier FROM agi_stac_v1.collection", new RowMapper<String>() {
            @Override
            public String mapRow(ResultSet rs, int rowNum) throws SQLException {
                String identifier = rs.getString(1);
                return identifier;
            }
            
        });
       
        log.info(foo.toString());
        
        
        return new ResponseEntity<List<String>>(foo, HttpStatus.OK);

        
    }

    
}
