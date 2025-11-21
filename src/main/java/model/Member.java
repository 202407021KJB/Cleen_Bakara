package model;

import java.time.LocalDate;

public class Member {
    private String userID;
    private String userPW;
    private String nickname;

    // 캐시 관련
    private int cash;                     // 보유 캐시
    private LocalDate lastLoginDate;      // 마지막 로그인 날짜

    public Member(String userID, String userPW, String nickname) {
        this.userID = userID;
        this.userPW = userPW;
        this.nickname = nickname;
        this.cash = 0;                    // 기본 캐시 0
        this.lastLoginDate = null;        // 아직 로그인 기록 없음
    }

    // Getter
    public String getUserID() { return userID; }
    public String getUserPW() { return userPW; }
    public String getNickname() { return nickname; }
    public int getCash() { return cash; }
    public LocalDate getLastLoginDate() { return lastLoginDate; }
    
    // Setter
    public void setUserPW(String userPW) { this.userPW = userPW; }
    public void setCash(int cash) { this.cash = cash; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public void setLastLoginDate(LocalDate lastLoginDate) { this.lastLoginDate = lastLoginDate; }
}
