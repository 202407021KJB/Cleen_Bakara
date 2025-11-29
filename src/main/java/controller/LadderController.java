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

        // --- 사다리 게임 세션 초기화 로직 ---
        if (session.getAttribute("ladderInitialCash") == null) {
            MemberDAO dao = new MemberDAO();
            Member member = dao.findMemberByID(userID);
            session.setAttribute("ladderInitialCash", member.getCash());
            session.setAttribute("ladderGameCount", 0);
        }
        // --- 세션 초기화 로직 끝 ---

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
            int pickIndex = Integer.parseInt(request.getParameter("pick"));
            int betAmount = Integer.parseInt(request.getParameter("bet"));

            if (players < 2 || players > 10) {
                throw new IllegalArgumentException("참가 인원은 2에서 10명 사이여야 합니다.");
            }
            if (betAmount <= 0 || member.getCash() < betAmount) {
                throw new IllegalArgumentException("보유 캐시가 부족하거나 올바르지 않은 금액입니다.");
            }

            // 게임 횟수 증가 및 세션 저장
            Integer gameCount = (Integer) session.getAttribute("ladderGameCount");
            if (gameCount == null) gameCount = 0;
            gameCount++;
            session.setAttribute("ladderGameCount", gameCount);

            // 게임 결과 조작 로직
            boolean forceLoss = false;
            Integer initialCash = (Integer) session.getAttribute("ladderInitialCash");
            if (initialCash != null && member.getCash() > initialCash) {
                int currentSpin = gameCount;
                int remainder = currentSpin % 10;
                if (currentSpin >= 11 && (remainder == 1 || remainder == 4 || remainder == 6 || remainder == 8)) {
                    forceLoss = true;
                }
            }

            // 결과 배열 생성 및 셔플
            List<String> results = new ArrayList<>();
            results.add("당첨");
            for (int i = 0; i < players - 1; i++) {
                results.add("꽝");
            }
            Collections.shuffle(results);

            // 사다리 데이터 생성
            List<LadderData.Rung> rungs = new ArrayList<>();
            Random rand = new Random();
            int rungCount = players * 2;
            for (int i = 0; i < rungCount * 2 && rungs.size() < rungCount; i++) {
                int col = rand.nextInt(players - 1);
                int y = rand.nextInt(230) + 80;
                
                final int finalY = y;
                boolean canPlace = !rungs.stream().anyMatch(r -> 
                    (r.col >= col - 1 && r.col <= col + 1) && (Math.abs(r.y - finalY) < 25)
                );

                if (canPlace) {
                    rungs.add(new LadderData.Rung(y, col));
                }
            }
            
            // 사다리 결과 계산
            rungs.sort(Comparator.comparingInt(r -> r.y));
            int endPos = pickIndex;
            for (LadderData.Rung rung : rungs) {
                if (rung.col == endPos) {
                    endPos++;
                } else if (rung.col == endPos - 1) {
                    endPos--;
                }
            }

            // 강제 패배 로직 적용
            if (forceLoss && results.get(endPos).equals("당첨")) {
                // "당첨"을 "꽝"으로 바꿈
                int winningIndex = endPos;
                int losingIndex = -1;
                for (int i = 0; i < results.size(); i++) {
                    if (results.get(i).equals("꽝")) {
                        losingIndex = i;
                        break;
                    }
                }
                if (losingIndex != -1) {
                    Collections.swap(results, winningIndex, losingIndex);
                }
            }

            // 승패 판정
            boolean isWin = results.get(endPos).equals("당첨");
            String message;
            double payout = (double) players;

            if (isWin) {
                GamecashManager.winGame(member, session, betAmount, payout);
                int prize = (int) (betAmount * payout);
                message = String.format("축하합니다! %,d 원에 당첨되었습니다!", prize);
            } else {
                GamecashManager.loseGame(member, session, betAmount);
                message = String.format("아쉽네요.. %,d 원을 잃었습니다.", betAmount);
            }

            // 결과 JSON 생성
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("ladderData", new LadderData(null, rungs)); 
            responseData.put("results", results);
            responseData.put("isWin", isWin);
            responseData.put("message", message);
            responseData.put("currentCash", member.getCash());

            response.getWriter().write(new Gson().toJson(responseData));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, String> errorData = new HashMap<>();
            errorData.put("error", e.getMessage());
            response.getWriter().write(new Gson().toJson(errorData));
        }
    }
}