package controller;

import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import model.Member;
import model.MemberDAO; // DB 연결을 위해 import

public class GamecashManager {

    private static final int JOIN_REWARD = 100_000;      // 회원가입 보상
    private static final int DAILY_LOGIN_REWARD = 10_000; // 매일 첫 로그인 보상

    // 회원가입 시 보너스 지급
    public static void giveJoinReward(Member member, HttpSession session) {
    	// 캐시에 10만원을 추가하여 반영
        member.setCash(member.getCash() + JOIN_REWARD);
        session.setAttribute("cash", member.getCash());

        // 가입 보너스 지급 후 DB 업데이트
        MemberDAO dao = new MemberDAO();
        dao.updateCashAndDate(member);
    }

    // 오늘 첫 로그인인지 체크 후 1만 지급
    public static void giveDailyLoginReward(Member member, HttpSession session) {
        LocalDate today = LocalDate.now();
        LocalDate lastLogin = member.getLastLoginDate();

        // 첫 로그인 또는 날짜가 다르면 지급
        if (lastLogin == null || !lastLogin.equals(today)) {
            member.setCash(member.getCash() + DAILY_LOGIN_REWARD);
            member.setLastLoginDate(today);
            session.setAttribute("cash", member.getCash());
            session.setAttribute("lastLoginDate", today.toString());
            
            // 알림 메시지 세션 저장
            session.setAttribute("alertMsg", "오늘 첫 로그인! 10,000 캐시가 지급되었습니다. 💰");

            // 변경된 날짜와 캐시를 DB에 저장
            MemberDAO dao = new MemberDAO();
            dao.updateCashAndDate(member);
        }
    }

    // 게임 승리 캐시 지급
    public static void winGame(Member member, HttpSession session,
                               int betAmount, double rate) {

        int reward = (int)(betAmount * rate);
        member.setCash(member.getCash() + reward);
        session.setAttribute("cash", member.getCash());

        // 게임 승리 후 늘어난 캐시 DB 저장
        MemberDAO dao = new MemberDAO();
        dao.updateCashAndDate(member);
    }

    // 게임 패배 캐시 차감
    public static void loseGame(Member member, HttpSession session,
                                int betAmount) {

        member.setCash(member.getCash() - betAmount);
        if (member.getCash() < 0) member.setCash(0);
        session.setAttribute("cash", member.getCash());

        // 게임 패배 후 줄어든 캐시 DB 저장
        MemberDAO dao = new MemberDAO();
        dao.updateCashAndDate(member);
    }
}