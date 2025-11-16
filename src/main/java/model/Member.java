package model;

public class Member
{
    private String userID;		// 아이디
    private String userPW;		// 비밀번호
    private String nickname;	// 별명

    // 생성자
    public Member(String userID, String userPW, String nickname)
    {
        this.userID = userID;
        this.userPW = userPW;
        this.nickname = nickname;
    }

    // Getter, Setter 추가
    public String getUserID()
    {
        return userID;
    }

    public String getUserPW()
    {
        return userPW;
    }

    public String getNickname()
    {
        return nickname;
    }
}