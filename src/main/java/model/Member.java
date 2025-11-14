package model;

public class Member
{
    private String userId;		// 아이디
    private String passwd;		// 비밀번호
    private String nickname;	// 별명

    // 생성자
    public Member(String userId, String passwd, String nickname)
    {
        this.userId = userId;
        this.passwd = passwd;
        this.nickname = nickname;
    }

    // Getter, Setter 추가
    public String getUserId()
    {
        return userId;
    }

    public String getPasswd()
    {
        return passwd;
    }

    public String getNickname()
    {
        return nickname;
    }
}