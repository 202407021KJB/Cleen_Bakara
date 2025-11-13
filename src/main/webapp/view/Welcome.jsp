<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String nickname = (String) session.getAttribute("nickname");
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

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<style>
  body
  {
    background-color: #f8f9fa;
  }

  .navbar
  {
    background-color: #2b2b2b;
  }

  .navbar-brand, .nav-link, .navbar-text
  {
    color: white !important;
  }

  .banner
  {
    background: linear-gradient(135deg, #007bff, #6610f2);
    color: white;
    text-align: center;
    padding: 60px 0;
    border-radius: 10px;
    margin: 30px 0 10px 0;
  }

  /* ✅ 캐러셀 화살표 색상 변경 (검정색) */
  .carousel-control-prev-icon,
  .carousel-control-next-icon
  {
    filter: invert(1);   /* 색상 반전 → 흰색 → 검정색 */
  }

  /* ✅ 캐러셀 이미지 스타일 */
  .carousel-item img
  {
    width: 100%;
    height: 400px;
    object-fit: cover;
    border-radius: 10px;
    transition: transform 0.4s ease;
    cursor: pointer;
  }

  .carousel-item img:hover
  {
    transform: scale(1.02);
  }

  /* ✅ 어두운 오버레이 추가 (텍스트 가독성) */
  .carousel-caption
  {
    background: rgba(0, 0, 0, 0.5);
    border-radius: 10px;
    padding: 20px;
  }

  footer
  {
    margin-top: 60px;
    text-align: center;
    color: gray;
    padding: 10px;
  }
</style>
</head>
<body>

<!-- ✅ 상단 네비게이션 -->
<nav class="navbar navbar-expand-lg">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">🎮 Cleen Bakara</a>

    <form class="d-flex" role="search">
      <input class="form-control me-2" type="search" placeholder="게임 검색..." aria-label="Search">
      <button class="btn btn-outline-light" type="submit">검색</button>
    </form>

    <ul class="navbar-nav ms-auto">
      <li class="nav-item">
        <!-- ✅ 아이디 대신 별명 출력 -->
        <span class="navbar-text me-3">안녕하세요, <strong><%= nickname %></strong> 님 👋</span>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="<%=request.getContextPath()%>/view/MyInfo.jsp">마이페이지</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="<%=request.getContextPath()%>/logout">로그아웃</a>
      </li>
    </ul>
  </div>
</nav>

<!-- ✅ 환영 배너 -->
<div class="container">
  <div class="banner">
    <h1>환영합니다 🎉</h1>
    <p>오늘도 Cleen Bakara에서 즐거운 하루를!</p>
  </div>

  <!-- ✅ 게임 배너 캐러셀 -->
  <div id="gameCarousel" class="carousel slide" data-bs-ride="carousel" style="margin-top: 30px;">
    <div class="carousel-inner">

      <!-- 🪜 사다리 타기 -->
      <div class="carousel-item active">
        <!-- ✅ [여기에 사다리 이미지 넣기] -->
        <a href="<%=request.getContextPath()%>/ladder">
          <img src="<%=request.getContextPath()%>/view/img/LadderImg.png" class="d-block w-100" alt="사다리 게임">
        </a>
        <div class="carousel-caption">
          <h3>🪜 사다리 타기</h3>
          <p>운명을 결정짓는 짜릿한 사다리!</p>
        </div>
      </div>

      <!-- 🎡 룰렛 게임 -->
      <div class="carousel-item">
        <!-- ✅ [여기에 룰렛 이미지 넣기] -->
        <a href="<%=request.getContextPath()%>/roulette">
          <img src="<%=request.getContextPath()%>/view/img/RouletteImg.png" class="d-block w-100" alt="룰렛 게임">
        </a>
        <div class="carousel-caption">
          <h3>🎡 룰렛 게임</h3>
          <p>돌려라! 당신의 행운을 시험해보세요!</p>
        </div>
      </div>
    </div>

    <!-- 화살표 컨트롤 -->
    <button class="carousel-control-prev" type="button" data-bs-target="#gameCarousel" data-bs-slide="prev">
      <span class="carousel-control-prev-icon" aria-hidden="true"></span>
      <span class="visually-hidden">이전</span>
    </button>
    <button class="carousel-control-next" type="button" data-bs-target="#gameCarousel" data-bs-slide="next">
      <span class="carousel-control-next-icon" aria-hidden="true"></span>
      <span class="visually-hidden">다음</span>
    </button>
  </div>
</div>

<footer>
  <p>© 2025 Cleen Bakara Team | All Rights Reserved</p>
</footer>

</body>
</html>