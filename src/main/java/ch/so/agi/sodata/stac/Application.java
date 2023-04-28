package ch.so.agi.sodata.stac;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import ch.so.agi.sodata.stac.service.ConfigService;

@SpringBootApplication
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}

    // Anwendung ist fertig gestartet: live aber nicht ready.
    @Bean
    CommandLineRunner init(ConfigService configService) {
        return args -> {
            
            System.out.println("Hallo Welt.");
            configService.parse();
        };
    }

}
