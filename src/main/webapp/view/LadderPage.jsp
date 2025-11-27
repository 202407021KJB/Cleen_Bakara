<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String countStr = request.getParameter("animalCount");
    int animalCount = 2; // Default to 2
    boolean isValid = true;
    if (countStr != null && !countStr.trim().isEmpty()) {
        try {
            int count = Integer.parseInt(countStr);
            if (count >= 2 && count <= 10) {
                animalCount = count;
            } else {
                isValid = false;
            }
        } catch (NumberFormatException e) {
            isValid = false;
        }
    }
    // 7마리 이상일 때 캔버스 너비 동적 조정
    int canvasWidth = (animalCount >= 7) ? 800 + (animalCount - 6) * 100 : 800;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>사다리 게임</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Ladder.css">
  <style>
    body { text-align: center; }
    h1 { margin-bottom: 15px !important; }
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
    #replay-btn { display: none; margin-top: 15px; }
    #ladder-container { position: relative; }
    #game-container { display: inline-block; position: relative; }
    .betting-box {
      background: white;
      padding: 10px 20px; /* Reduced padding */
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      text-align: center;
      display: inline-block;
      margin-bottom: 10px; /* Reduced margin */
    }
    .betting-box h3 {
        font-size: 1.2rem; /* Reduced font size */
        margin-bottom: 8px; /* Reduced margin */
    }
    .regenerate-controls {
      margin-top: 8px; /* Reduced margin */
      padding-top: 8px; /* Reduced padding */
      border-top: 1px solid #eee;
      text-align: right;
    }
    .regenerate-controls label { font-size: 0.8em; }
    .regenerate-controls .bet-input { width: 55px; font-size: 0.8em; padding: 4px; }
    .regenerate-controls .btn { font-size: 0.8em; padding: 4px 8px; }
  </style>
</head>
<body>

  <a href="<%=request.getContextPath()%>/view/MainPage.jsp" id="lobby-btn">로비로 가기</a>
  
  <h1>🪜 사다리 게임</h1>

<% if(isValid) { %>
  <div class="betting-box">
    <%
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
      <form id="regenerate-form" onsubmit="handleRegenerate(); return false;" style="display: inline-flex; align-items: center; gap: 8px;">
          <label for="animalCountInput">참가 동물 수:</label>
          <input type="number" id="animalCountInput" class="bet-input" value="<%= animalCount %>" min="2" max="10">
          <button type="submit" class="btn btn-secondary">변경</button>
      </form>
    </div>
  </div>

  <div id="game-container" 
       data-context-path="<%=request.getContextPath()%>" 
       data-animal-count="<%=animalCount%>">
    
    <div id="ladder-container">
      <canvas id="ladderCanvas" width="<%=canvasWidth%>" height="400"></canvas>
      <!-- Player inputs and result outputs will be injected here by JS -->
    </div>
    
    <button id="replay-btn" class="btn btn-success">다시하기</button>
  </div>
<% } else { %>
    <div class="alert alert-danger"><h4>오류</h4><p>잘못된 접근입니다. 2에서 10 사이의 값을 선택해주세요.</p><a href="<%=request.getContextPath()%>/view/MainPage.jsp" class="btn btn-primary">메인으로 돌아가기</a></div>
<% } %>
  <script src="<%=request.getContextPath()%>/view/LadderGame.js"></script>

</body>
</html>