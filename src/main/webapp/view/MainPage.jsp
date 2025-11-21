<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 정보 확인
    String nickname = (String) session.getAttribute("saveName");
    String userID = (String) session.getAttribute("userID");
    Object cashObj = session.getAttribute("cash"); // 캐시 가져오기
    
    // 캐시가 null이면 0으로 처리 (안전장치)
    int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    
    boolean isLoggedIn = (nickname != null && userID != null);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Welcome - Cleen Bakara</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/MainPage.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>

<nav class="navbar navbar-expand-lg">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">🎮 Cleen Bakara</a>

    <ul class="navbar-nav ms-auto">
      
      <li class="nav-item d-flex align-items-center">
        <% if (isLoggedIn) { %>
            <div style="text-align: right; margin-right: 15px; line-height: 1.2;">
                <span class="navbar-text" style="display: block; padding: 0; font-size: 14px;">
                    안녕하세요, <strong><%= nickname %></strong> 님
                </span>
                <span class="navbar-text" style="display: block; padding: 0; font-size: 13px; color: #f1c40f !important;">
                    💰 <strong><%= String.format("%,d", currentCash) %></strong> 원
                </span>
            </div>
        <% } else { %>
            <span class="navbar-text me-3">로그인 후 이용해 주세요.</span>
        <% } %>
      </li>

      <% if (isLoggedIn) { %>
        <li class="nav-item">
          <a class="menu-btn" href="<%=request.getContextPath()%>/view/MyInfo.jsp">마이페이지</a>
        </li>
        <li class="nav-item">
          <a class="menu-btn" href="#" onclick="confirmLogout()">로그아웃</a>
        </li>
      <% } else { %>
        <li class="nav-item">
          <a class="menu-btn" href="<%=request.getContextPath()%>/view/LoginPage.jsp">로그인</a>
        </li>
        <li class="nav-item">
          <a class="menu-btn" href="<%=request.getContextPath()%>/view/SignUpPage.jsp">회원가입</a>
        </li>
      <% } %>
    </ul>
  </div>
</nav>

<div class="container">
  <div class="banner">
    <h1>환영합니다 🎉</h1>
    <p>오늘도 Cleen Bakara에서 즐거운 하루를!</p>
  </div>

  <div id="gameCarousel" class="carousel slide" data-bs-ride="carousel">
    <div class="carousel-indicators">
      <button type="button" data-bs-target="#gameCarousel" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
      <button type="button" data-bs-target="#gameCarousel" data-bs-slide-to="1" aria-label="Slide 2"></button>
    </div>
    <div class="carousel-inner">
      <div class="carousel-item active">
        <a href="<%=request.getContextPath()%>/ladder">
          <img src="<%=request.getContextPath()%>/view/img/LadderImg.png" class="d-block w-100" alt="사다리 게임">
        </a>
        <div class="carousel-caption">
          <h3>🪜 사다리 타기</h3>
          <p>운명을 결정짓는 짜릿한 사다리!</p>
        </div>
      </div>
      <div class="carousel-item">
        <a href="<%=request.getContextPath()%>/roulette">
          <img src="<%=request.getContextPath()%>/view/img/RouletteImg.png" class="d-block w-100" alt="룰렛 게임">
        </a>
        <div class="carousel-caption">
          <h3>🎡 룰렛 게임</h3>
          <p>돌려라! 당신의 행운을 시험해보세요!</p>
        </div>
      </div>
    </div>
  </div>
</div>

<footer>
  <p>JSP 과제 | 조영록 | 문건우 | 김종범</p>
</footer>

<script>
const CONTEXT_PATH = "<%=request.getContextPath()%>";
function confirmLogout() {
    if (confirm("정말 로그아웃 하시겠습니까?")) {
        location.href = CONTEXT_PATH + "/logout";
    }
}
</script>
</body>
</html>