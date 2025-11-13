package model;

public class Member
{
    private String userId;   // 사용자 아이디
    private String passwd;   // 비밀번호
    private String nickname; // 별명 (새로 추가)

    public Member(String userId, String passwd, String nickname)
    {
        this.userId = userId;
        this.passwd = passwd;
        this.nickname = nickname;
    }

    // ✅ 기본 생성자 (JSP/DAO 등에서 필요할 수 있음)
    public Member() {}

    public String getUserId() { return userId; }
    public String getPasswd() { return passwd; }
    public String getNickname() { return nickname; }

    public void setUserId(String userId) { this.userId = userId; }
    public void setPasswd(String passwd) { this.passwd = passwd; }
    public void setNickname(String nickname) { this.nickname = nickname; }
}