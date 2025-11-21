package controller;

import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;
import model.LadderData;
import model.Member;
import model.MemberDAO;

@WebServlet("/ladder")
public class LadderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 로그인 체크
        HttpSession session = request.getSession(false);
        String userID = (session != null) ? (String) session.getAttribute("userID") : null;
        
        if (userID == null) {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?error=need_login");
            return;
        }

        // 2. 페이지 로드 요청 (파라미터가 없는 경우)
        if (request.getParameter("players") == null) {
            RequestDispatcher dispatcher = request.getRequestDispatcher("/view/LadderPage.jsp");
            dispatcher.forward(request, response);
            return;
        }

        // 3. 게임 데이터 요청 및 베팅 처리
        response.setContentType("application/json; charset=UTF-8");
        MemberDAO dao = new MemberDAO();
        Member member = dao.findMemberByID(userID);

        try {
            int players = Integer.parseInt(request.getParameter("players"));
            int pickIndex = Integer.parseInt(request.getParameter("pick")); // 유저 선택 (0:좌, 1:우)
            int betAmount = Integer.parseInt(request.getParameter("bet"));  // 베팅 금액

            // 예외 처리
            if (betAmount <= 0 || member.getCash() < betAmount) {
                throw new IllegalArgumentException("보유 캐시가 부족하거나 올바르지 않은 금액입니다.");
            }

            // 사다리 데이터 생성
            List<Integer> xPositions = new ArrayList<>();
            List<LadderData.Rung> rungs = new ArrayList<>();
            int ladderLeft = 50, ladderRight = 450;
            int stepX = (ladderRight - ladderLeft) / (players - 1);
            for (int i = 0; i < players; i++) xPositions.add(ladderLeft + i * stepX);

            Random rand = new Random();
            for (int y = 70; y < 350; y += 30) {
                for (int i = 0; i < players - 1; i++) {
                    if (rand.nextBoolean()) rungs.add(new LadderData.Rung(y, i));
                }
            }
            
            // 사다리 결과 계산
            rungs.sort(Comparator.comparingInt(r -> r.y));
            int currentPos = pickIndex;
            for (LadderData.Rung rung : rungs) {
                if (rung.col == currentPos) currentPos++;
                else if (rung.col == currentPos - 1) currentPos--;
            }

            // 승패 판정 (0번 도착=당첨, 1번 도착=꽝)
            boolean isWin = (currentPos == 0); 
            String message;
            
            if (isWin) {
                GamecashManager.winGame(member, session, betAmount, 2.0); // 2배 지급
                message = "축하합니다! 당첨되었습니다! (+" + (betAmount * 2) + "원)";
            } else {
                GamecashManager.loseGame(member, session, betAmount);
                message = "아쉽네요.. 꽝입니다. (-" + betAmount + "원)";
            }

            // 결과 JSON 생성
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("ladderData", new LadderData(xPositions, rungs));
            responseData.put("resultIndex", currentPos);
            responseData.put("isWin", isWin);
            responseData.put("message", message);
            responseData.put("currentCash", member.getCash());

            response.getWriter().write(new Gson().toJson(responseData));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            
            // 🚨 수정 전 (위험함): 수동 문자열 조합
            // response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");

            // ✅ 수정 후 (안전함): Gson을 사용하여 JSON 생성
            Map<String, String> errorData = new HashMap<>();
            errorData.put("error", e.getMessage()); // Gson이 특수문자 등을 자동으로 처리해줍니다.
            response.getWriter().write(new Gson().toJson(errorData));
        }
    }
}