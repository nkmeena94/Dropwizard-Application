package myApp.modules.operations;

import com.google.inject.Inject;
import myApp.entity.Admins;

public class AdminsOps {
    @Inject
    public AdminsOps() {
    }

    public Admins getAllActiveAdmins(){
        Admins admin = new Admins();
        admin.setId(1);
        admin.setName("Naval Meena");
        admin.setDesignation("Admin");
        admin.setMobileNo("7309273874");
        return admin;
    }
}
