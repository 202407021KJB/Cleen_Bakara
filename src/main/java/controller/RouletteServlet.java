package controller;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * 룰렛 게임의 서버 측 로직을 담당하는 서블릿입니다.
 * 클라이언트 스크립트에 **미리 정의된 옵션 목록**을 받아,
 * 그중 하나를 무작위로 '당첨자'로 선택하여 JSON 형태로 응답합니다。
 * URL 패턴: /roulette
 */
@WebServlet("/roulette")
public class RouletteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Random random = new Random(); // 무작위 선택을 위한 Random 객체

    /**
     * 클라이언트의 GET 요청을 처리하는 메소드입니다.
     * (HTTP Method: GET, URL: /roulette?option=사과&option=바나나)
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("--- RouletteServlet doGet() 호출됨 ---");

        // 1. 클라이언트의 JavaScript 파일에 하드코딩된 옵션 목록을 파라미터로 읽어옵니다.
        // getParameterValues는 동일한 이름(option)으로 전달된 여러 값들을 배열로 받아옵니다.
        String[] options = req.getParameterValues("option");

        System.out.println("전달받은 옵션: " + (options != null ? Arrays.toString(options) : "null"));

        // 2. 옵션이 없는 경우, 잘못된 요청으로 간주하고 400 에러를 응답합니다.
        if (options == null || options.length == 0) {
            System.out.println("오류: 옵션이 없습니다. 400 Bad Request 응답 전송");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "옵션이 전달되지 않았습니다.");
            return;
        }

        // 3. 전달받은 옵션 중에서 하나를 무작위로 선택합니다.
        List<String> optionList = Arrays.asList(options);
        // random.nextInt(N)은 0부터 N-1까지의 정수 중 하나를 무작위로 반환합니다.
        String winner = optionList.get(random.nextInt(optionList.size()));

        System.out.println("선택된 당첨자: " + winner);

        // 4. 클라이언트에 JSON 형태로 응답합니다.
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        // GSON 같은 라이브러리를 사용할 수도 있지만, 구조가 단순하여 직접 문자열을 만듭니다.
        // 예: {"winner": "바나나"}
        String jsonResponse = String.format("{\"winner\": \"%s\"}", winner);
        
        resp.getWriter().write(jsonResponse);
        System.out.println("JSON 응답 전송 완료: " + jsonResponse);
    }
}
