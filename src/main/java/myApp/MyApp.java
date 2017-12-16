package myApp;

import com.google.inject.Guice;
import com.google.inject.Injector;
import io.dropwizard.Application;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import myApp.modules.resources.AdminsResources;
import myApp.server.MyAppModule;

public class MyApp extends Application<MyAppConfiguration> {

    public static void main(String args[]) throws Exception{
        System.out.println("Hello");
        new MyApp().run(args);
    }
    @Override
    public void initialize(Bootstrap<MyAppConfiguration> bootstrap) {

    }


    @Override
    public void run(MyAppConfiguration configuration, Environment environment) throws Exception {
        //final AdminsResources resources = new
        Injector injector = createInjector(configuration, environment);
        environment.jersey().register(injector.getInstance(AdminsResources.class));
    }

    private Injector createInjector(MyAppConfiguration configuration, Environment environment) {
        return Guice.createInjector(new MyAppModule(configuration, environment));
    }

}
