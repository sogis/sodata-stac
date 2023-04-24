package ch.so.agi.sodata.stac.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ConfigService {
    private final Logger log = LoggerFactory.getLogger(this.getClass());

    @Value("${app.configFile}")
    private String CONFIG_FILE;   

    public void parse() {
        
    }
}
