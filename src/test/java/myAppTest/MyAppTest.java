package myAppTest;

import org.junit.Test;

import javax.ws.rs.client.Entity;
import javax.ws.rs.core.Response;

public class MyAppTest extends BaseTest {

    @Test
    public void test(){
        Response resp = client.target("http://localhost:" + RULE.getLocalPort() + "/myproject/Admins/getAllActiveAdmins")
                .request().get();
        String strResp = resp.readEntity(String.class);
        System.out.println(strResp);
    }
}
