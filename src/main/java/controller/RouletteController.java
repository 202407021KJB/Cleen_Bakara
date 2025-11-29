/**
 * 파일명: RouletteController.java
 * 설명: 룰렛 게임의 백엔드 로직을 처리하는 서블릿 컨트롤러입니다.
 *       게임 페이지 로드, 베팅 처리, 룰렛 결과 계산(조작 로직 포함), 사용자 캐시 업데이트 등을 관리합니다.
 *
 * 전체 실행 흐름 (Roulette 게임):
 * 1.  클라이언트(브라우저)에서 '/roulette' URL로 GET 요청을 보냅니다 (최초 페이지 로드 또는 게임 옵션 변경).
 * 2.  doGet() 메서드에서 로그인 여부를 확인합니다. 로그인되지 않았다면 로그인 페이지로 리다이렉트합니다.
 * 3.  최초 페이지 로드 요청일 경우 (option 파라미터가 없는 경우), 세션을 초기화하고 (초기 캐시, 게임 횟수)
 *     요청 파라미터(`fruitCount`)에 따라 룰렛 옵션(과일 목록)을 생성합니다.
 *     생성된 옵션과 배당률 정보를 `RoulettePage.jsp` 뷰로 포워드하여 게임 화면을 사용자에게 보여줍니다.
 * 4.  사용자가 'RoulettePage.jsp'에서 베팅을 하고 스핀 버튼을 누르면, RouletteGame.js (클라이언트 JavaScript)에서
 *     베팅 정보 및 선택 옵션과 함께 '/roulette' URL로 다시 GET 요청(AJAX)을 보냅니다.
 * 5.  doGet() 메서드는 요청 파라미터를 분석하여 게임 로직을 실행합니다.
 *     - MemberDAO를 통해 사용자 정보를 가져와 캐시를 확인합니다.
 *     - 게임 횟수를 증가시키고, 특정 조건(초기 캐시 대비 현재 캐시 증가 및 특정 게임 횟수)에 따라 '강제 패배' 조작 로직을 적용합니다.
 *     - 룰렛의 최종 당첨 옵션을 결정합니다. (조작 로직이 적용되면 사용자가 선택하지 않은 옵션 중 하나를 강제로 당첨시킴)
 *     - GamecashManager를 호출하여 사용자의 게임 캐시를 업데이트합니다 (승패에 따라 증가/감소).
 *     - 게임 결과(당첨 옵션, 승패 여부, 메시지, 최종 캐시)를 JSON 형태로 클라이언트에 응답합니다.
 * 6.  클라이언트(RouletteGame.js)는 서버로부터 받은 JSON 응답을 바탕으로 룰렛 애니메이션을 보여주고,
 *     결과 메시지 및 캐시 잔액을 화면에 업데이트합니다.
 */
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
public class RouletteController extends HttpServlet 
{

    private static final List<String> FRUIT_NAMES = Arrays.asList(
        "사과", "레몬", "멜론", "블루베리", "오렌지", "포도", "감", "배", "라임", "복숭아"
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
    {

        // 1. 로그인 체크: 세션에서 사용자 ID를 확인하여 로그인 여부를 검증합니다.
        HttpSession session = request.getSession(false);
        String userID = (session != null) ? (String) session.getAttribute("userID") : null;
        
        // 로그인되지 않았다면 로그인 페이지로 리다이렉트하고 함수를 종료합니다.
        if (userID == null) 
        {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?error=need_login");
            return;
        }

        // --- 룰렛 게임 세션 초기화 로직: 세션 내 초기 캐시 및 게임 횟수 설정 ---
        // 이 로직은 세션당 한 번만 실행되어야 합니다.
        if (session.getAttribute("rouletteInitialCash") == null) 
        {
            MemberDAO dao = new MemberDAO();
            Member member = dao.findMemberByID(userID);
            session.setAttribute("rouletteInitialCash", member.getCash());
            session.setAttribute("rouletteGameCount", 0);
            // System.out.println("[Roulette] Initializing session for userID: " + userID + ", initialCash: " + member.getCash() + ", gameCount: 0"); // Optional logging
        }
        // --- 세션 초기화 로직 끝 ---

        // 2. 페이지 로드 요청 처리: 'option' 파라미터가 없는 경우 (최초 페이지 로드 또는 과일 수 변경 요청),
        //    룰렛 게임 화면을 구성하기 위한 데이터를 준비하고 JSP 뷰를 반환합니다.
        if (request.getParameterValues("option") == null) 
        {
            // 'fruitCount' 파라미터를 파싱하여 룰렛 옵션의 개수를 결정합니다.
            String fruitCountStr = request.getParameter("fruitCount");
            int fruitCount = 2; // 기본 과일 옵션 개수
            if (fruitCountStr != null && !fruitCountStr.isEmpty()) 
            {
                try 
                {
                    fruitCount = Integer.parseInt(fruitCountStr);
                    // 유효성 검사: FRUIT_NAMES 리스트 범위 내에서 2개 이상 선택 가능
                    if (fruitCount < 2 || fruitCount > FRUIT_NAMES.size()) 
                    {
                        fruitCount = 2; // 허용 범위 벗어나면 기본값으로 설정
                    }
                } 
                catch (NumberFormatException e) 
                {
                    fruitCount = 2; // 숫자가 아닌 값이 들어오면 기본값으로 설정
                }
            }

            // FRUIT_NAMES 리스트에서 결정된 'fruitCount'만큼 과일 목록을 생성합니다.
            List<String> fruitList = new ArrayList<>(FRUIT_NAMES.subList(0, fruitCount));

            // 생성된 과일 목록과 배당률을 JSP로 전달합니다.
            request.setAttribute("fruitList", fruitList);
            request.setAttribute("payoutRate", fruitList.size()); // 배당률은 과일 옵션 개수와 동일

            // 'RoulettePage.jsp' 뷰로 포워드하여 룰렛 게임 화면을 표시합니다.
            RequestDispatcher dispatcher = request.getRequestDispatcher("/view/RoulettePage.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        // 3. 게임 로직 및 베팅 처리 (AJAX 요청): 클라이언트로부터 게임 시작 요청을 받아 룰렛을 돌리고 결과를 반환합니다.
        response.setContentType("application/json; charset=UTF-8"); // JSON 응답을 위한 Content-Type 설정
        MemberDAO dao = new MemberDAO(); // 회원 데이터 접근 객체
        Member member = dao.findMemberByID(userID); // 현재 로그인한 회원 정보 조회

        try 
        {
            // 3.1. 요청 파라미터 파싱 및 유효성 검사
            String[] options = request.getParameterValues("option"); // 룰렛 옵션 목록 (과일 이름)
            String userPick = request.getParameter("userPick");       // 사용자가 베팅한 옵션
            int betAmount = Integer.parseInt(request.getParameter("bet")); // 베팅 금액

            if (options == null || options.length < 2) throw new IllegalArgumentException("옵션이 부족합니다.");
            if (betAmount <= 0 || member.getCash() < betAmount) throw new IllegalArgumentException("보유 캐시가 부족합니다.");

            // 3.2. 게임 횟수 증가 및 세션 저장: 게임 조작 로직에 사용될 현재 게임 횟수를 업데이트합니다.
            Integer gameCount = (Integer) session.getAttribute("rouletteGameCount");
            if (gameCount == null) gameCount = 0;
            gameCount++;
            session.setAttribute("rouletteGameCount", gameCount);

            // 3.3. 게임 결과 조작 로직: 사용자의 캐시가 초기 캐시보다 증가했을 경우,
            //      특정 게임 횟수에서 강제로 패배하게 만듭니다. (게임머니 소진 유도)
            boolean forceLoss = false;
            Integer initialCash = (Integer) session.getAttribute("rouletteInitialCash");
            
            // 초기 금액보다 현재 금액이 높을 때만 조작 로직 발동
            if (initialCash != null && member.getCash() > initialCash) 
            {
                int currentSpin = gameCount; // 현재 스핀 횟수
                int remainder = currentSpin % 10;
                // 11, 14, 16, 18, 21, 24, 26, 28 ... 패턴으로 강제 패배 유도
                if (currentSpin >= 11 && (remainder == 1 || remainder == 4 || remainder == 6 || remainder == 8))
                {
                    forceLoss = true;
                }
            }

            // 3.4. 룰렛 당첨 옵션 결정
            String winner;
            Random rand = new Random();

            if (forceLoss) 
            { // 강제 패배 조건이 만족된 경우
                List<String> nonUserPicks = new ArrayList<>();
                // 사용자가 선택하지 않은 옵션들 중에서 당첨 옵션을 무작위로 선택
                for (String option : options) 
                {
                    if (!option.equals(userPick)) 
                    {
                        nonUserPicks.add(option);
                    }
                }
                if (!nonUserPicks.isEmpty()) 
                {
                    winner = nonUserPicks.get(rand.nextInt(nonUserPicks.size())); // 사용자가 선택하지 않은 것 중 랜덤
                } 
                else 
                {
                    // 이 경우는 모든 옵션이 userPick과 같아서 강제 패배가 불가능할 때 발생 (예외 상황)
                    winner = userPick; 
                }
            } 
            else 
            { // 일반적인 경우: 모든 옵션 중에서 무작위로 당첨 옵션 선택
                winner = options[rand.nextInt(options.length)];
            }

            // 3.5. 승패 판정 및 캐시 업데이트
            boolean isWin = winner.equals(userPick); // 사용자가 선택한 옵션과 당첨 옵션이 일치하는지 확인
            String message;

            if (isWin) 
            {
                double rate = (double) options.length; // 배당률은 룰렛 옵션 개수와 동일
                GamecashManager.winGame(member, session, betAmount, rate); // 게임 승리 처리 (캐시 증가)
                message = "대박! " + winner + " 당첨! (+" + String.format("%,d", (int)(betAmount * rate)) + "원)";
            } 
            else 
            {
                GamecashManager.loseGame(member, session, betAmount); // 게임 패배 처리 (캐시 감소)
                message = "저런... 결과는 " + winner + " 입니다. (-" + String.format("%,d", betAmount) + "원)";
            }

            // 3.6. 결과 JSON 생성 및 응답
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("winner", winner); // 최종 당첨 옵션
            responseData.put("isWin", isWin);     // 승리 여부
            responseData.put("message", message); // 사용자에게 보여줄 메시지
            responseData.put("currentCash", member.getCash()); // 업데이트된 현재 캐시 잔액

            response.getWriter().write(new Gson().toJson(responseData)); // JSON 데이터를 응답으로 전송

        } 
        catch (Exception e) 
        {
            // 3.7. 오류 처리: 예외 발생 시 클라이언트에 오류 메시지를 JSON 형태로 전송합니다.
            e.printStackTrace(); // 에러 로그 출력 (디버깅용)
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 클라이언트에 400 Bad Request 상태 코드 전송
            Map<String, String> errorData = new HashMap<>();
            errorData.put("error", e.getMessage()); // 오류 메시지 포함
            response.getWriter().write(new Gson().toJson(errorData)); // 오류 정보를 JSON으로 응답
        }
    }
}