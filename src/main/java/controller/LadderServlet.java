package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

/**
 * 사다리 게임의 서버 측 로직을 담당하는 서블릿입니다.
 * 클라이언트의 요청에 따라 **고정된 2인용** 사다리 데이터를 무작위로 생성하고,
 * JSON 형태로 응답합니다.
 * URL 패턴: /ladder
 */
@WebServlet("/ladder")
public class LadderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Random random = new Random(); // 무작위 가로대를 생성하기 위한 Random 객체

    // JSON 응답 구조에 맞게 내부 데이터 클래스를 정의합니다.
    // 가로대(Rung)의 y좌표와 시작 세로줄(col) 정보를 가집니다.
    private static class Rung {
        int y;
        int col;

        Rung(int y, int col) {
            this.y = y;
            this.col = col;
        }
    }

    // 최종적으로 클라이언트에 전달될 사다리 데이터 전체를 담는 클래스입니다.
    private static class LadderData {
        List<Double> xPositions; // 세로줄들의 x좌표 목록
        List<Rung> rungs;        // 가로대들의 정보 목록

        LadderData(List<Double> xPositions, List<Rung> rungs) {
            this.xPositions = xPositions;
            this.rungs = rungs;
        }
    }

    /**
     * 클라이언트의 GET 요청을 처리하는 메소드입니다.
     * (HTTP Method: GET, URL: /ladder?players=2)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("--- LadderServlet doGet() 호출됨 ---");
        try {
            // 1. 클라이언트에서 보낸 고정된 참가자 수(2)를 파라미터로 읽어옵니다.
            int numPlayers = Integer.parseInt(request.getParameter("players"));
            if (numPlayers < 2) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "플레이어는 2명 이상이어야 합니다.");
                return;
            }

            // 2. 사다리 데이터 생성 로직
            double ladderTop = 50;
            double ladderBottom = 350;
            double ladderLeft = 50;
            double ladderRight = 450;

            // 참가자 수에 맞춰 세로줄의 x좌표를 균등하게 계산합니다.
            double stepX = (ladderRight - ladderLeft) / (numPlayers - 1);
            List<Double> xPositions = new ArrayList<>();
            for (int i = 0; i < numPlayers; i++) {
                xPositions.add(ladderLeft + i * stepX);
            }

            // 무작위로 가로대를 생성합니다.
            List<Rung> rungs = new ArrayList<>();
            int yStep = 28; // 가로줄이 그려질 y축 간격
            for (int y = (int) ladderTop + 20; y < ladderBottom - 20; y += yStep) {
                List<Integer> placedInLevel = new ArrayList<>(); // 같은 y레벨에 겹쳐서 가로대가 생기지 않도록 체크하는 리스트
                for (int i = 0; i < numPlayers - 1; i++) {
                    if (placedInLevel.contains(i)) continue; // 이미 현재 위치에 가로대가 놓여있으면 건너뜀
                    
                    // 50% 확률로 가로대를 놓습니다.
                    if (random.nextFloat() > 0.5) {
                        rungs.add(new Rung(y, i));
                        // 가로대가 놓이면, 해당 가로대가 차지하는 두 세로줄(i, i+1)에는 더 이상 가로대를 놓지 않도록 기록합니다.
                        placedInLevel.add(i);
                        placedInLevel.add(i + 1);
                    }
                }
            }

            // 생성된 데이터를 최종 객체에 담습니다.
            LadderData ladderData = new LadderData(xPositions, rungs);

            // 3. GSON 라이브러리를 사용하여 생성된 자바 객체를 JSON 문자열로 변환합니다.
            String jsonResponse = new Gson().toJson(ladderData);

            // 4. 클라이언트에 JSON 형태로 응답합니다.
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonResponse);
            System.out.println("사다리 데이터 JSON 응답 완료");

        } catch (NumberFormatException e) {
            // 'players' 파라미터가 숫자가 아닐 경우 예외 처리
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "플레이어 수가 올바르지 않습니다.");
        } catch (Exception e) {
            // 기타 예외 처리
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "사다리 데이터 생성 중 오류 발생");
        }
    }
}
