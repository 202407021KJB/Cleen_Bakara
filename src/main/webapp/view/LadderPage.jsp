<%--

  파일명: LadderPage.jsp
  설명: 사다리 게임의 사용자 인터페이스(View)를 제공하는 JSP 페이지입니다.
      게임 화면 구성 및 사용자 입력을 처리하며, LadderGame.js와 연동하여 동적인 게임 경험을 제공합니다.
 
  전체 실행 흐름에서의 역할:
  1.  LadderController의 doGet() 메서드에서 로그인 체크 후, 최초 페이지 로드 요청 시 이 JSP로 포워드됩니다.
  2.  페이지 로드 시, 세션에서 사용자 캐시 정보를 가져와 화면에 표시합니다.
  3.  사용자는 이 페이지에서 베팅 금액 및 참가 동물 수(옵션)를 설정하고 게임을 시작합니다.
  4.  사용자가 게임 시작 버튼을 누르면, LadderGame.js가 이 페이지의 HTML 요소들을 조작하고
     LadderController에 게임 실행 요청(AJAX)을 보냅니다.
  5.  LadderController로부터 게임 결과를 받으면, LadderGame.js가 이 페이지의 캔버스에 사다리 애니메이션과 결과를 그립니다.
 
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ================================================================
    // [기능] URL 파라미터 'animalCount' 처리 및 유효성 검사
    //   - 사용자로부터 사다리 게임의 참가 동물 수를 입력받습니다.
    //   - 2에서 10 사이의 유효한 값만 허용하며, 유효하지 않을 경우 기본값 3을 사용합니다.
    //   - 페이지 로드 시 게임 설정의 기초가 됩니다.
    // ================================================================
    String countStr = request.getParameter("animalCount");
    int animalCount = 3; // 기본 참가 동물 수
    boolean isValid = true; // 파라미터의 유효성 여부
    if (countStr != null && !countStr.trim().isEmpty()) {
        try {
            int count = Integer.parseInt(countStr);
            if (count >= 2 && count <= 10) {
                animalCount = count; // 유효한 값일 경우 설정
            } else {
                isValid = false; // 유효 범위 밖
            }
        } catch (NumberFormatException e) {
            isValid = false; // 숫자가 아닌 경우
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>사다리 게임</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Ladder.css">
</head>
<body>

  <a href="<%=request.getContextPath()%>/view/MainPage.jsp" id="lobby-btn">로비로 가기</a>
  
  <h1>🪜 사다리 게임</h1>

<% if(isValid) { %>
  <%--
    ================================================================
    [기능] 게임 설정 및 베팅 UI
      - 'isValid' 값이 true일 때만 게임 관련 UI를 표시합니다.
      - 현재 사용자 보유 캐시를 표시하고, 베팅 금액을 입력받습니다.
      - 참가 동물 수를 변경하여 새로운 사다리 게임을 생성할 수 있습니다.
    ================================================================
  --%>
  <div class="betting-box">
    <%
        // 세션에서 사용자 캐시 정보를 가져와 표시합니다.
        Object cashObj = session.getAttribute("cash");
        int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    %>
    <h3>보유 캐시: <span id="my-cash" style="color: #27ae60; font-weight: bold;"><%= String.format("%,d", currentCash) %></span> 원</h3>
    
    <div>
      <label for="betAmount">베팅 금액: </label>
      <input type="number" id="betAmount" class="bet-input" value="1000" min="100" step="100"> 원
      <span style="font-size: 0.8em; color: #555;">(배당률: <%= animalCount %>배)</span>
    </div>

    <div class="regenerate-controls">
      <%-- 게임 재설정 폼: 참가 동물 수를 변경하고 사다리를 다시 생성합니다. --%>
      <form id="regenerate-form" onsubmit="handleRegenerate(); return false;" style="display: inline-flex; align-items: center; gap: 8px;">
          <label for="animalCountInput">참가 동물 수:</label>
          <input type="number" id="animalCountInput" class="bet-input" value="<%= animalCount %>" min="2" max="10">
          <button type="submit" class="btn btn-secondary">변경</button>
      </form>
    </div>
  </div>

  <%--
    ================================================================
    [기능] 사다리 게임 컨테이너 및 캔버스
      - 실제 사다리 게임이 그려질 영역을 제공합니다.
      - `data-context-path`와 `data-animal-count` 속성은 JavaScript (LadderGame.js)에서 게임 초기화 시 사용됩니다.
      - `ladderCanvas`는 사다리 라인과 애니메이션을 렌더링하는 핵심 요소입니다.
    ================================================================
  --%>
  <div id="game-container" 
       data-context-path="<%=request.getContextPath()%>" 
       data-animal-count="<%=animalCount%>">
    
    <div id="ladder-container">
      <canvas id="ladderCanvas" width="800" height="400"></canvas>
      <!-- Player inputs and result outputs will be injected here by JS -->
    </div>
    
    <button id="replay-btn" class="btn btn-success">다시하기</button>
  </div>
<% } else { %>
    <%--
      ================================================================
      [기능] 유효하지 않은 접근 처리
        - 'animalCount' 파라미터가 유효하지 않을 경우 사용자에게 오류 메시지를 표시합니다.
        - 메인 페이지로 돌아가는 버튼을 제공하여 사용자가 올바른 경로로 이동할 수 있도록 안내합니다.
      ================================================================
    --%>
    <div class="alert alert-danger"><h4>오류</h4><p>잘못된 접근입니다. 2에서 10 사이의 값을 선택해주세요.</p><a href="<%=request.getContextPath()%>/view/MainPage.jsp" class="btn btn-primary">메인으로 돌아가기</a></div>
<% } %>
  <%--
    ================================================================
    [기능] 사다리 게임 클라이언트 측 로직 포함
      - LadderGame.js 파일을 로드하여 사다리 게임의 동적인 동작(그리기, 애니메이션, 서버 통신)을 처리합니다.
      - 이 스크립트는 페이지 로드 후 실행되어 사다리 게임 UI를 완성합니다.
    ================================================================
  --%>
  <script src="<%=request.getContextPath()%>/view/LadderGame.js"></script>

</body>
</html>