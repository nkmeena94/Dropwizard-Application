package myApp.server;

import com.google.inject.AbstractModule;
import io.dropwizard.setup.Environment;
import myApp.MyAppConfiguration;
import myApp.modules.operations.AdminsOps;

public class MyAppModule extends AbstractModule {
    private final MyAppConfiguration configuration;
    private final Environment environment;
    //private final DBI dbi;

    public MyAppModule(MyAppConfiguration configuration, Environment environment) {
        this.configuration = configuration;
        this.environment = environment;
    }

    protected void configure() {
        bind(MyAppConfiguration.class).toInstance(configuration);
    }
}
