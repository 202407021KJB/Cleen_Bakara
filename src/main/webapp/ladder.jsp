<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title> 사다리 게임 </title>
  <style>
    /* 전체 페이지 스타일 */
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 20px;
        margin: 0;
        background-color: #f4f7f9;
        color: #333;
    }
    h1 {
        color: #2c3e50;
        margin-bottom: 30px;
    }
    /* 게임 전체를 감싸는 컨테이너 */
    #game-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 15px;
    }
    /* 시작점(좌,우)과 결과(당첨,꽝) 영역의 스타일 */
    #player-inputs, #result-outputs {
        display: flex;
        justify-content: space-around;
        width: 500px;
    }
    /* 원형 박스 스타일 */
    .player-box, .result-box {
        width: 80px;
        height: 80px;
        display: flex;
        justify-content: center;
        align-items: center;
        border-radius: 50%; /* 원형으로 변경 */
        background-color: #ffffff;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        font-size: 16px;
        font-weight: bold;
        color: #34495e;
        border: 2px solid #e0e0e0;
        transition: all 0.3s ease;
        cursor: pointer; /* 클릭 가능함을 표시 */
    }
    .player-box:hover {
        transform: scale(1.05);
        border-color: #3498db;
    }
    /* 원형 박스 안의 input 태그 스타일 */
    .player-box input, .result-box input {
        width: 100%;
        border: none;
        background: transparent;
        text-align: center;
        font-size: 1em;
        font-weight: bold;
        color: inherit;
        pointer-events: none; /* input 자체는 클릭되지 않도록 설정 */
    }
    /* 사다리가 그려질 캔버스 스타일 */
    #ladderCanvas {
        border: 1px solid #e0e0e0;
        border-radius: 12px; /* 둥근 모서리 */
        background-color: #ffffff;
        box-shadow: 0 5px 15px rgba(0,0,0,0.08);
    }
    /* 버튼 공통 스타일 */
    .btn {
        padding: 12px 25px;
        border: none;
        background: #3498db;
        color: #fff;
        border-radius: 8px;
        cursor: pointer;
        margin: 10px;
        font-size: 16px;
        font-weight: bold;
        transition: background-color 0.3s, transform 0.1s;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .btn:disabled {
        background: #bdc3c7;
        cursor: not-allowed;
    }
    .btn:not(:disabled):hover {
        background: #2980b9;
    }
    .btn:not(:disabled):active {
        transform: translateY(1px);
        box-shadow: 0 1px 2px rgba(0,0,0,0.1);
    }
    /* '로비로 가기' 버튼 스타일 */
    #lobby-btn {
        position: absolute;
        top: 20px;
        left: 20px;
        padding: 10px 15px;
        background-color: #95a5a6;
        color: white;
        text-decoration: none;
        border-radius: 8px;
        font-size: 14px;
        transition: background-color 0.3s;
    }
    #lobby-btn:hover {
        background-color: #7f8c8d;
    }
  </style>
</head>
<body>
  <!-- 최상단에 위치한 로비 이동 링크 -->
  <a href="index.html" id="lobby-btn">로비로 가기</a>
  
  <h1>사다리 게임</h1>

  <!-- 
    게임의 주요 UI 요소들을 담는 컨테이너입니다.
    'data-context-path' 속성은 JavaScript에서 서버 경로를 올바르게 찾기 위해 사용됩니다.
  -->
  <div id="game-container" data-context-path="${pageContext.request.contextPath}">
    
    <!-- '좌', '우' 시작점이 표시될 영역 -->
    <div id="player-inputs"></div>
    
    <!-- 사다리 그림이 그려질 캔버스 영역 -->
    <div id="ladder-container">
      <canvas id="ladderCanvas" width="500" height="400"></canvas>
    </div>
    
    <!-- '당첨', '꽝' 결과가 표시될 영역 -->
    <div id="result-outputs"></div>
  </div>

  <!-- 게임 컨트롤 버튼 영역 -->
  <div>
    <button id="startBtn" class="btn">사다리 생성</button>
  </div>

  <!-- 
    사다리 게임의 모든 클라이언트 사이드 로직을 담고 있는 
    JavaScript 파일을 불러옵니다.
  -->
  <script src="view/game.js"></script>
</body>
</html>
