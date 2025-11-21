<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>사다리 게임</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Ladder.css">
</head>
<body>

  <a href="<%=request.getContextPath()%>/mainpage" id="lobby-btn">로비로 가기</a>
  
  <h1>🪜 사다리 게임</h1>

  <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); text-align: center; margin-bottom: 20px; width: fit-content;">
    <h3>보유 캐시: <span id="my-cash" style="color: #27ae60; font-weight: bold;"><%= session.getAttribute("cash") %></span> 원</h3>
    
    <label for="betAmount">베팅 금액: </label>
    <input type="number" id="betAmount" value="1000" min="100" step="100" style="padding: 5px; width: 100px; text-align: right;"> 원
    
    <p style="font-size: 0.9em; color: gray; margin-top: 5px;">
        (아래 '좌' 또는 '우' 버튼을 클릭하면 게임이 시작됩니다)
    </p>
  </div>

  <div id="game-container" data-context-path="${pageContext.request.contextPath}">
    
    <div id="player-inputs"></div>
    
    <div id="ladder-container">
      <canvas id="ladderCanvas" width="500" height="400"></canvas>
    </div>
    
    <div id="result-outputs"></div>
  </div>

  <script src="<%=request.getContextPath()%>/view/LadderGame.js"></script>

</body>
</html>