package ch.so.agi.sodata.stac;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.jdbc.JdbcConnectionDetails;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import ch.so.agi.sodata.stac.service.ConfigService;

//@SpringBootApplication
@Configuration
//@EnableAutoConfiguration 
//@ComponentScan
@ConditionalOnProperty(
        name = "spring.profiles.active",
        havingValue = "dev",
        matchIfMissing = false)
public class TestApplication {
    
//    @Autowired
//    PostgreSQLContainer postgres;

//    @Autowired
//    JdbcConnectionDetails postgres;
    
    public static void main(String[] args) {
//        SpringApplication.from(Application::main).with(MyContainersConfiguration.class).run(args);
        SpringApplication.from(Application::main).run(args);
    }
    
    @Bean
    CommandLineRunner devInit(JdbcConnectionDetails postgres, ConfigService configService) {
        return args -> {
            
            System.out.println("Hallo Welt.lkj lkj ");
//            System.out.println(postgres.getJdbcUrl());
            System.out.println(postgres.getJdbcUrl());
//            System.out.println(postgres.getDatabaseName());
            //configService.parse();
        };
    }

}
