package myApp.entity;

public class Admins {

    private long id;
    private String name;
    private String mobileNo;
    private String designation;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getMobileNo() {
        return mobileNo;
    }

    public void setMobileNo(String mobileNo) {
        this.mobileNo = mobileNo;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    @Override
    public String toString() {
        return "Admins{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", mobileNo='" + mobileNo + '\'' +
                ", designation='" + designation + '\'' +
                '}';
    }
}
