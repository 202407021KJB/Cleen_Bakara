<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) 
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
    margin: 30px 0;
  }
  
  .game-card 
  {
    transition: 0.3s;
    cursor: pointer;
  }
  
  .game-card:hover 
  {
    transform: scale(1.05);
    box-shadow: 0 5px 20px rgba(0,0,0,0.2);
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
        <span class="navbar-text me-3">안녕하세요, <strong><%= userId %></strong> 님 👋</span>
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

<!-- ✅ 배너 -->
<div class="container">
  <div class="banner">
    <h1>환영합니다 🎉</h1>
    <p>오늘도 Cleen Bakara에서 즐거운 하루를!</p>
  </div>

  <!-- ✅ 게임 카드 -->
  <div class="row justify-content-center">
    <!-- 사다리 게임 -->
    <div class="col-md-4 mb-4">
      <div class="card game-card" onclick="location.href='<%=request.getContextPath()%>/ladder'">
        <img src="<%=request.getContextPath()%>/view/img/ladder.jpg" class="card-img-top" alt="사다리 게임">
        <div class="card-body text-center">
          <h5 class="card-title">사다리 게임</h5>
          <p class="card-text">운명을 결정짓는 사다리 타기 게임!</p>
        </div>
      </div>
    </div>

    <!-- 룰렛 게임 -->
    <div class="col-md-4 mb-4">
      <div class="card game-card" onclick="location.href='<%=request.getContextPath()%>/roulette'">
        <img src="<%=request.getContextPath()%>/view/img/roulette.jpg" class="card-img-top" alt="룰렛 게임">
        <div class="card-body text-center">
          <h5 class="card-title">룰렛 게임</h5>
          <p class="card-text">행운의 룰렛을 돌려보세요!</p>
        </div>
      </div>
    </div>
  </div>
</div>

<footer>
  <p>© 2025 Cleen Bakara Team | All Rights Reserved</p>
</footer>
</body>
</html>