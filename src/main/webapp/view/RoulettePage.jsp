<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>룰렛 게임</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Roulette.css">
  <style>
    .bet-input {
      border: 2px solid #ddd;
      border-radius: 8px;
      padding: 8px 12px;
      font-size: 0.9em;
      font-weight: bold;
      text-align: center;
      width: 80px;
      transition: all 0.3s ease;
      -moz-appearance: textfield;
    }
    .bet-input::-webkit-outer-spin-button,
    .bet-input::-webkit-inner-spin-button {
      -webkit-appearance: none;
      margin: 0;
    }
    .bet-input:focus {
      border-color: #4ECCA3;
      box-shadow: 0 0 8px rgba(78, 204, 163, 0.5);
      outline: none;
    }
    /* Styles from LadderPage for consistency */
    .regenerate-controls {
      margin-top: 12px; /* Consistent spacing */
      padding-top: 8px; /* Reduced for tighter look */
      border-top: 1px solid #eee;
      text-align: center; /* Changed to center */
    }
    .regenerate-controls label { font-size: 0.8em; }
    .regenerate-controls .bet-input { width: 55px; font-size: 0.8em; padding: 4px; }
    .regenerate-controls .btn { font-size: 0.8em; padding: 4px 8px; }
  </style>
</head>
<body>

  <a href="<%=request.getContextPath()%>/mainpage" id="lobby-btn">로비로 가기</a>

  <h1>🎡 룰렛 게임</h1>

  <div style="background: white; padding: 15px; margin: 10px auto; width: 350px; border-radius: 10px; text-align: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
    <%
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
      <form id="regenerate-form" style="display: inline-flex; align-items: center; gap: 8px;">
          <label for="fruitCountInput">과일 개수:</label>
          <input type="number" id="fruitCountInput" class="bet-input" value="${payoutRate}" min="2" max="10">
          <button type="submit" class="btn btn-secondary">변경</button>
      </form>
    </div>
  </div>

  <div id="game-container" data-context-path="${pageContext.request.contextPath}">
    <div id="canvas-container">
      <div id="pointer"></div>
      <canvas id="roulette-canvas" width="500" height="500"></canvas>
    </div>
  </div>

  <script>
    // 컨트롤러에서 받은 과일 리스트를 JavaScript 배열(options)로 변환
    const options = [
      <c:forEach var="item" items="${fruitList}" varStatus="status">
        "${item}"<c:if test="${!status.last}">,</c:if>
      </c:forEach>
    ];
  </script>
  <script src="<%=request.getContextPath()%>/view/RouletteGame.js"></script>

</body>
</html>