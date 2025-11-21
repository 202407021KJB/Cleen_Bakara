package controller;

import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;
import model.RouletteData;
import model.Member;
import model.MemberDAO;

@WebServlet("/roulette")
public class RouletteController extends HttpServlet {

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

        // 2. 페이지 로드 요청
        if (request.getParameterValues("option") == null) {
            RequestDispatcher dispatcher = request.getRequestDispatcher("/view/RoulettePage.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        // 3. 게임 로직 및 베팅 처리
        response.setContentType("application/json; charset=UTF-8");
        MemberDAO dao = new MemberDAO();
        Member member = dao.findMemberByID(userID);

        try {
            String[] options = request.getParameterValues("option");
            String userPick = request.getParameter("userPick");
            int betAmount = Integer.parseInt(request.getParameter("bet"));

            if (options == null || options.length < 2) throw new IllegalArgumentException("옵션이 부족합니다.");
            if (betAmount <= 0 || member.getCash() < betAmount) throw new IllegalArgumentException("보유 캐시가 부족합니다.");

            // 랜덤 승자 결정
            Random rand = new Random();
            String winner = options[rand.nextInt(options.length)];

            boolean isWin = winner.equals(userPick);
            String message;

            if (isWin) {
                double rate = (double) options.length; // 옵션 개수만큼 배율 적용
                GamecashManager.winGame(member, session, betAmount, rate);
                message = "대박! " + winner + " 당첨! (+" + (int)(betAmount * rate) + "원)";
            } else {
                GamecashManager.loseGame(member, session, betAmount);
                message = "저런... 결과는 " + winner + " 입니다. (-" + betAmount + "원)";
            }

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("winner", winner);
            responseData.put("isWin", isWin);
            responseData.put("message", message);
            responseData.put("currentCash", member.getCash());

            response.getWriter().write(new Gson().toJson(responseData));

        } catch (Exception e) {
            e.printStackTrace(); // 에러 로그 출력
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

            // ✅ 수정 후: Gson 사용
            Map<String, String> errorData = new HashMap<>();
            errorData.put("error", e.getMessage());
            response.getWriter().write(new Gson().toJson(errorData));
        }
    }
}