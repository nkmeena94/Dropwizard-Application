package myAppTest;

import io.dropwizard.testing.ResourceHelpers;
import io.dropwizard.testing.junit.DropwizardAppRule;
import myApp.MyApp;
import myApp.MyAppConfiguration;
import org.junit.After;
import org.junit.Before;
import org.junit.ClassRule;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;

public class BaseTest {
    private static final String CONFIG_PATH = ResourceHelpers.resourceFilePath("properties.yml");
    @ClassRule
    public static final DropwizardAppRule<MyAppConfiguration> RULE = new DropwizardAppRule<MyAppConfiguration>(
            MyApp.class, CONFIG_PATH);

    protected Client client = ClientBuilder.newClient();
    protected MyApp myApp;

    @Before
    public void setUp() throws Exception {
        myApp = RULE.getApplication();
    }

    @After
    public void tearDown() throws Exception {
        client.close();
    }
}
