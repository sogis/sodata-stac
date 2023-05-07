package ch.so.agi.sodata.stac;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.test.context.ActiveProfiles;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import static org.junit.jupiter.api.Assertions.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.BeforeAll;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Testcontainers
@ActiveProfiles("test")
class ApplicationTests {
    @LocalServerPort
    private int port;
    
    @Autowired
    private TestRestTemplate restTemplate;

    private static String WAIT_PATTERN = ".*database system is ready to accept connections.*\\s";

    // static: will be shared between test methods
    // non static: will be started before and stopped after each test method
    @Container
    @ServiceConnection
    public static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>(
            DockerImageName.parse("sogis/postgis:15-3.3").asCompatibleSubstituteFor("postgres"))
            .withDatabaseName("edit").withUsername(TestUtil.PG_CON_DDLUSER)
            .withPassword(TestUtil.PG_CON_DDLPASS)
            .waitingFor(Wait.forLogMessage(WAIT_PATTERN, 2));

    @BeforeAll
    public static void init() {
        TestUtil.importXtf(postgres.getJdbcUrl());
    }
	
	@Test
	public void catalog_Ok() throws IOException {
	    String response = this.restTemplate.getForObject("http://localhost:" + port + "/catalog.json", String.class);
	    String expected = Files.readString(Path.of("src/test/data/catalog_expected.json"));
	    assertEquals(response.replace("http://localhost:"+port, "http://localhost"), expected);
	}

	@Test
	public void collection_Ok() throws IOException {
	    String response = this.restTemplate.getForObject("http://localhost:" + port + "/ch.so.alw.strukturverbesserungen/collection.json", String.class);
	    String expected = Files.readString(Path.of("src/test/data/collection_expected.json"));
	    assertEquals(response.replace("http://localhost:"+port, "http://localhost"), expected);
	}
	
   @Test
    public void item_Ok() throws IOException {
        String response = this.restTemplate.getForObject("http://localhost:" + port + "/ch.so.alw.strukturverbesserungen/ch.so.alw.strukturverbesserungen/ch.so.alw.strukturverbesserungen.json", String.class);
        String expected = Files.readString(Path.of("src/test/data/item_expected.json"));
        assertEquals(response.replace("http://localhost:"+port, "http://localhost"), expected);
    }
}
