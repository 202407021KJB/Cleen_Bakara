<%--

  파일명: RoulettePage.jsp
  설명: 룰렛 게임의 사용자 인터페이스(View)를 제공하는 JSP 페이지입니다.
        룰렛 게임 화면 구성 및 사용자 입력을 처리하며, RouletteGame.js와 연동하여 동적인 게임 경험을 제공합니다.
 
  전체 실행 흐름에서의 역할:
  1.  RouletteController의 doGet() 메서드에서 로그인 체크 후, 최초 페이지 로드 요청 시 이 JSP로 포워드됩니다.
  2.  페이지 로드 시, RouletteController로부터 전달받은 과일 옵션 리스트와 세션에서 사용자 캐시 정보를 가져와 화면에 표시합니다.
  3.  사용자는 이 페이지에서 베팅 금액을 설정하고 룰렛 스핀을 시작합니다.
  4.  사용자가 스핀 버튼을 누르면, RouletteGame.js가 이 페이지의 HTML 요소들을 조작하고
      RouletteController에 게임 실행 요청(AJAX)을 보냅니다.
  5.  RouletteController로부터 게임 결과(당첨 옵션, 승패 여부, 최종 캐시)를 받으면, RouletteGame.js가 이 페이지의 캔버스에
      룰렛 애니메이션을 보여주고 최종 결과 및 캐시 잔액을 업데이트합니다.
 
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>룰렛 게임</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Roulette.css">
</head>
<body>

  <%-- 로비로 돌아가는 버튼 --%>
  <a href="<%=request.getContextPath()%>/mainpage" id="lobby-btn">로비로 가기</a>

  <h1>🎡 룰렛 게임</h1>

  <div class="betting-box">
    <%
        // 세션에서 사용자 캐시 정보를 가져와 표시합니다.
        Object cashObj = session.getAttribute("cash");
        int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    %>
    <h3>보유 캐시: <span id="my-cash" style="color: #e67e22;"><%= String.format("%,d", currentCash) %></span> 원</h3>
    
    <div>
       <label for="betAmount">베팅 금액: </label>
       <input type="number" id="betAmount" class="bet-input" value="1000" min="100" step="100"> 원
       <span style="font-size: 0.8em; color: #555;">(배당률: ${payoutRate}배)</span>
    </div>

    <div class="regenerate-controls">
      <%-- 룰렛 과일 개수 변경 폼 --%>
      <form id="regenerate-form" style="display: inline-flex; align-items: center; gap: 8px;">
          <label for="fruitCountInput">과일 개수:</label>
          <input type="number" id="fruitCountInput" class="bet-input" value="${payoutRate}" min="2" max="10">
          <button type="submit" class="btn btn-secondary">변경</button>
      </form>
    </div>
  </div>

  <%-- 룰렛 게임 컨테이너: 포인터와 캔버스를 포함합니다. --%>
  <div id="game-container" data-context-path="${pageContext.request.contextPath}">
    <div id="canvas-container">
      <div id="pointer"></div> <%-- 룰렛이 멈추는 곳을 가리키는 포인터 --%>
      <canvas id="roulette-canvas" width="500" height="500"></canvas> <%-- 룰렛 휠이 그려질 캔버스 --%>
    </div>
  </div>

  <script>
    // 컨트롤러에서 받은 과일 리스트를 JavaScript 배열(options)로 변환하여 클라이언트 측에서 사용합니다.
    const options = [
      <c:forEach var="item" items="${fruitList}" varStatus="status">
        "${item}"<c:if test="${!status.last}">,</c:if>
      </c:forEach>
    ];
  </script>
  <%-- 룰렛 게임 클라이언트 측 로직 (JavaScript) --%>
  <script src="<%=request.getContextPath()%>/view/RouletteGame.js"></script>

</body>
</html>