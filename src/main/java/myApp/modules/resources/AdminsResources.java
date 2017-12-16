package myApp.modules.resources;

import com.codahale.metrics.annotation.Timed;
import myApp.entity.Admins;
import myApp.modules.operations.AdminsOps;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/myproject/Admins")
@Produces(MediaType.APPLICATION_JSON)
public class AdminsResources {

    private final AdminsOps adminsOps;

    @Inject
    public AdminsResources(AdminsOps adminsOps) {
        this.adminsOps = adminsOps;
    }
    @GET
    @Timed
    @Path("/getAllActiveAdmins")
    public Admins getAllActiveAdmins(){
        return adminsOps.getAllActiveAdmins();

    }
}
