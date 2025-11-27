package controller;

import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;
import java.util.Arrays;
import model.RouletteData;
import model.Member;
import model.MemberDAO;

@WebServlet("/roulette")
public class RouletteController extends HttpServlet {

    private static final List<String> FRUIT_NAMES = Arrays.asList(
        "사과", "레몬", "멜론", "블루베리", "오렌지", "포도", "감", "배", "라임", "복숭아"
    );

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

        // 2. 페이지 로드 요청 (fruitCount 파라미터가 있을 때)
        if (request.getParameterValues("option") == null) {
            // --- 세션 초기화 로직 ---
            if (session.getAttribute("rouletteInitialCash") == null) {
                MemberDAO dao = new MemberDAO();
                Member member = dao.findMemberByID(userID);
                session.setAttribute("rouletteInitialCash", member.getCash());
                session.setAttribute("rouletteGameCount", 0);
            }
            // --- 세션 초기화 로직 끝 ---

            String fruitCountStr = request.getParameter("fruitCount");
            int fruitCount = 2; // 기본값
            if (fruitCountStr != null && !fruitCountStr.isEmpty()) {
                try {
                    fruitCount = Integer.parseInt(fruitCountStr);
                    if (fruitCount < 2 || fruitCount > FRUIT_NAMES.size()) {
                        fruitCount = 2; // 허용 범위 (2-10) 벗어나면 기본값으로
                    }
                } catch (NumberFormatException e) {
                    fruitCount = 2; // 숫자가 아닌 값이 들어오면 기본값으로
                }
            }

            // 과일 리스트 생성
            List<String> fruitList = new ArrayList<>(FRUIT_NAMES.subList(0, fruitCount));

            // JSP로 데이터 전달
            request.setAttribute("fruitList", fruitList);
            request.setAttribute("payoutRate", fruitList.size()); // 배당률 정보 추가
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("/view/RoulettePage.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        // 3. 게임 로직 및 베팅 처리 (AJAX 요청)
        response.setContentType("application/json; charset=UTF-8");
        MemberDAO dao = new MemberDAO();
        Member member = dao.findMemberByID(userID);

        try {
            String[] options = request.getParameterValues("option");
            String userPick = request.getParameter("userPick");
            int betAmount = Integer.parseInt(request.getParameter("bet"));

            if (options == null || options.length < 2) throw new IllegalArgumentException("옵션이 부족합니다.");
            if (betAmount <= 0 || member.getCash() < betAmount) throw new IllegalArgumentException("보유 캐시가 부족합니다.");

            // --- 게임 횟수 증가 및 세션 저장 ---
            Integer gameCount = (Integer) session.getAttribute("rouletteGameCount");
            if (gameCount == null) gameCount = 0;
            gameCount++;
            session.setAttribute("rouletteGameCount", gameCount);
            // --- 게임 횟수 증가 및 세션 저장 끝 ---

            // --- 조작 로직 시작 ---
            boolean forceLoss = false;
            Integer initialCash = (Integer) session.getAttribute("rouletteInitialCash");
            
            if (initialCash != null && member.getCash() > initialCash) { // 초기 금액보다 현재 금액이 높을 때만 조작
                int currentSpin = gameCount; // 현재 스핀 횟수
                int remainder = currentSpin % 10;
                // 11, 14, 16, 18, 21, 24, 26, 28 ... 패턴
                if (currentSpin >= 11 && (remainder == 1 || remainder == 4 || remainder == 6 || remainder == 8)) {
                    forceLoss = true;
                }
            }

            String winner;
            Random rand = new Random();

            if (forceLoss) {
                List<String> nonUserPicks = new ArrayList<>();
                for (String option : options) {
                    if (!option.equals(userPick)) {
                        nonUserPicks.add(option);
                    }
                }
                if (!nonUserPicks.isEmpty()) {
                    winner = nonUserPicks.get(rand.nextInt(nonUserPicks.size()));
                } else {
                    // 이 경우는 options.length가 1이거나, 모든 옵션이 userPick과 같을 때 발생.
                    // 현재 로직상 options.length는 최소 2이므로 발생하지 않아야 함.
                    // 만약 발생하면, 강제 패배가 불가능하므로 userPick을 당첨으로 처리 (예외 상황)
                    winner = userPick; 
                }
            } else {
                winner = options[rand.nextInt(options.length)];
            }
            // --- 조작 로직 끝 ---

            boolean isWin = winner.equals(userPick);
            String message;

            if (isWin) {
                double rate = (double) options.length; // 옵션 개수만큼 배율 적용
                GamecashManager.winGame(member, session, betAmount, rate);
                message = "대박! " + winner + " 당첨! (+" + String.format("%,d", (int)(betAmount * rate)) + "원)";
            } else {
                GamecashManager.loseGame(member, session, betAmount);
                message = "저런... 결과는 " + winner + " 입니다. (-" + String.format("%,d", betAmount) + "원)";
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
            Map<String, String> errorData = new HashMap<>();
            errorData.put("error", e.getMessage());
            response.getWriter().write(new Gson().toJson(errorData));
        }
    }
}