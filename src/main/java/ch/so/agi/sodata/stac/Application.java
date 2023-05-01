package ch.so.agi.sodata.stac;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.filter.ForwardedHeaderFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import ch.so.agi.sodata.stac.service.ConfigService;

@SpringBootApplication
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}

    @Bean
    ForwardedHeaderFilter forwardedHeaderFilter() {
        return new ForwardedHeaderFilter();
    } 

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**").allowedMethods("GET")
                .allowedOrigins("*")
                .allowedHeaders("*");
            }
        };
    }

	
    // Anwendung ist fertig gestartet: live aber nicht ready.
//    @Bean
//    CommandLineRunner init(ConfigService configService) {
//        return args -> {
//            
//            System.out.println("Hallo Welt.");
//            configService.parse();
//        };
//    }

}
