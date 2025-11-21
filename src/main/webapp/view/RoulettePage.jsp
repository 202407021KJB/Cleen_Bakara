<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>룰렛 게임</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Roulette.css">
</head>
<body>

  <a href="<%=request.getContextPath()%>/mainpage" id="lobby-btn">로비로 가기</a>

  <h1>🎡 룰렛 게임</h1>

  <div style="background: white; padding: 15px; margin: 10px auto; width: 300px; border-radius: 10px; text-align: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
    <h3>보유 캐시: <span id="my-cash" style="color: #e67e22;"><%= session.getAttribute("cash") %></span> 원</h3>
    
    <div style="margin: 10px 0;">
       <label for="userPick">걸고 싶은 곳: </label>
       <select id="userPick" style="padding: 5px;">
         <option value="사과">🍎 사과</option>
         <option value="바나나">🍌 바나나</option>
       </select>
    </div>

    <div>
       <label for="betAmount">베팅 금액: </label>
       <input type="number" id="betAmount" value="1000" min="100" step="100" style="width: 80px; padding: 5px; text-align: right;"> 원
    </div>
  </div>

  <div id="game-container" data-context-path="${pageContext.request.contextPath}">
    <div id="canvas-container">
      <div id="pointer"></div>
      <canvas id="roulette-canvas" width="500" height="500"></canvas>
    </div>
    
    <button id="spin-btn" class="btn">돌리기!</button>
  </div>

  <script src="<%=request.getContextPath()%>/view/RouletteGame.js"></script>

</body>
</html>