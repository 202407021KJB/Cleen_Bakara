<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 로그인 세션 확인
    String nickname = (String) session.getAttribute("saveName");

    if (nickname == null)
    {
        response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp?error=session");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Welcome - Cleen Bakara</title>

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Welcome.css -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Welcome.css">

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</head>
<body>

<!-- 상단 내비게이션 바 -->
<nav class="navbar navbar-expand-lg">
  <div class="container-fluid">

    <!-- 왼쪽 로고 -->
    <a class="navbar-brand" href="#">🎮 Cleen Bakara</a>

    <!-- 중앙 검색창 -->
    <form class="search-bar">
      <input class="search-input" type="search" placeholder="게임 검색..." aria-label="Search">
    </form>

    <!-- 오른쪽 메뉴 -->
    <ul class="navbar-nav ms-auto">

      <li class="nav-item">
        <span class="navbar-text me-3">
          안녕하세요, <strong><%= nickname %></strong> 님 👋
        </span>
      </li>

      <li class="nav-item">
        <a class="menu-btn" href="<%=request.getContextPath()%>/view/MyInfo.jsp">마이페이지</a>
      </li>

      <li class="nav-item">
        <a class="menu-btn" href="#" onclick="confirmLogout()">로그아웃</a>
      </li>

    </ul>
  </div>
</nav>

<!-- 환영 배너 -->
<div class="container">
  <div class="banner">
    <h1>환영합니다 🎉</h1>
    <p>오늘도 Cleen Bakara에서 즐거운 하루를!</p>
  </div>

  <!-- 게임 배너 캐러셀 -->
  <div id="gameCarousel" class="carousel slide" data-bs-ride="carousel" style="margin-top: 30px;">
    <div class="carousel-inner">

      <!-- 사다리 게임 -->
      <div class="carousel-item active">
        <a href="<%=request.getContextPath()%>/ladder">
          <img src="<%=request.getContextPath()%>/view/img/LadderImg.png" class="d-block w-100" alt="사다리 게임">
        </a>
        <div class="carousel-caption">
          <h3>🪜 사다리 타기</h3>
          <p>운명을 결정짓는 짜릿한 사다리!</p>
        </div>
      </div>

      <!-- 룰렛 게임 -->
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

    <!-- 화살표 버튼 -->
    <button class="carousel-control-prev" type="button" data-bs-target="#gameCarousel" data-bs-slide="prev">
      <span class="carousel-control-prev-icon"></span>
    </button>
    <button class="carousel-control-next" type="button" data-bs-target="#gameCarousel" data-bs-slide="next">
      <span class="carousel-control-next-icon"></span>
    </button>

  </div>
</div>

<footer>
  <p>© 2025 Cleen Bakara Team | All Rights Reserved</p>
</footer>

<!-- 로그아웃 팝업 -->
<script>
function confirmLogout()
{
    if (confirm("정말 로그아웃 하시겠습니까?"))
    {
        location.href = "<%=request.getContextPath()%>/logout";
    }
}
</script>

</body>
</html>