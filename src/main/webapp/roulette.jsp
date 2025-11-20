<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>룰렛 게임</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
    h1 { color: #333; }
    #game-container { display: inline-block; margin-top: 20px; }
    /* 룰렛과 포인터를 담는 컨테이너 */
    #canvas-container { position: relative; width: 500px; height: 500px; }
    /* 룰렛 상단의 빨간색 화살표(포인터) 스타일 */
    #pointer { position: absolute; left: 50%; top: -10px; transform: translateX(-50%); width: 0; height: 0; border-left: 20px solid transparent; border-right: 20px solid transparent; border-top: 30px solid red; z-index: 10; }
    canvas { display: block; }
    .controls { margin-top: 20px; }
    /* 버튼 공통 스타일 */
    .btn { padding: 10px 16px; border: none; background: #007bff; color: #fff; border-radius: 6px; cursor: pointer; margin: 5px; }
    .btn:disabled { background: #ccc; }
    #options-container input { margin: 2px 5px; width: 100px; }
    /* '로비로 가기' 버튼 스타일 */
    #lobby-btn {
      position: absolute;
      top: 20px;
      left: 20px;
      padding: 10px 15px;
      background-color: #6c757d;
      color: white;
      text-decoration: none;
      border-radius: 5px;
      font-size: 14px;
    }
  </style>
</head>
<body>

  <!-- 최상단에 위치한 로비 이동 링크 -->
  <a href="index.html" id="lobby-btn">로비로 가기</a>

  <h1>룰렛 게임</h1>

  <!-- 
    게임의 주요 UI 요소들을 담는 컨테이너입니다.
    'data-context-path' 속성은 JavaScript에서 서버 경로를 올바르게 찾기 위해 사용됩니다.
  -->
  <div id="game-container" data-context-path="${pageContext.request.contextPath}">
    <!-- 룰렛 캔버스와 포인터를 감싸는 컨테이너 -->
    <div id="canvas-container">
      <div id="pointer"></div>
      <canvas id="roulette-canvas" width="500" height="500"></canvas>
    </div>
    <!-- 룰렛 돌리기 버튼 -->
    <button id="spin-btn" class="btn">돌리기!</button>
  </div>

  <!-- 
    룰렛 게임의 모든 클라이언트 사이드 로직을 담고 있는 
    JavaScript 파일을 불러옵니다.
  -->
  <script src="view/roulette.js"></script>
</body>
</html>
