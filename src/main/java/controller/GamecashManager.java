package controller;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import model.Member;

public class GamecashManager {

    private static final int JOIN_REWARD = 100_000;      // 회원가입 보상
    private static final int DAILY_LOGIN_REWARD = 10_000; // 매일 첫 로그인 보상

    // 🔹 회원가입 시 보너스 지급
    public static void giveJoinReward(Member member, HttpSession session) {
        member.setCash(member.getCash() + JOIN_REWARD);
        session.setAttribute("cash", member.getCash());
    }

    // 🔹 오늘 첫 로그인인지 체크 후 1만 지급
    public static void giveDailyLoginReward(Member member, HttpSession session) {
        LocalDate today = LocalDate.now();
        LocalDate lastLogin = member.getLastLoginDate();

        // 첫 로그인 또는 날짜가 다르면 지급
        if (lastLogin == null || !lastLogin.equals(today)) {
            member.setCash(member.getCash() + DAILY_LOGIN_REWARD);
            member.setLastLoginDate(today);
            session.setAttribute("cash", member.getCash());
            session.setAttribute("lastLoginDate", today.toString());
            System.out.println("<script> alert('오늘 첫 로그인 1만 캐시가 지급 되었습니다.');");
        }
    }

    // 🔹 게임 승리 캐시 지급
    public static void winGame(Member member, HttpSession session,
                               int betAmount, double rate) {

        int reward = (int)(betAmount * rate);
        member.setCash(member.getCash() + reward);
        session.setAttribute("cash", member.getCash());
    }

    // 🔹 게임 패배 캐시 차감
    public static void loseGame(Member member, HttpSession session,
                                int betAmount) {

        member.setCash(member.getCash() - betAmount);
        if (member.getCash() < 0) member.setCash(0);
        session.setAttribute("cash", member.getCash());
    }
}
