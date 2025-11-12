package model;

public class Member {
    private String userId;
    private String passwd;

    public Member() {}
    public Member(String userId, String passwd) 
    {
        this.userId = userId;
        this.passwd = passwd;
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getPasswd() { return passwd; }
    public void setPasswd(String passwd) { this.passwd = passwd; }
}