<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>로그인 - Cleen Bakara</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/LoginPage.css">
</head>
<body>

<%
    String msgParam = request.getParameter("msg");
    if ("join_success".equals(msgParam)) {
%>
    <script>
        alert("회원가입을 축하합니다! 🎉\n가입 보상 100,000 캐시가 지급되었습니다.");
    </script>
<%
    }
%>

<nav class="navbar">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">🎮 Cleen Bakara</a>
    <ul class="navbar-nav ms-auto"></ul>
  </div>
</nav>

<div class="form-container">
    <h2>로그인</h2>

    <form action="<%=request.getContextPath()%>/login" method="post">
        <div class="input-group">
            <input type="text" name="userID" placeholder="아이디" required>
        </div>
        <div class="input-group">
            <input type="password" name="userPW" placeholder="비밀번호" required>
        </div>
        <button type="submit" class="submit-btn">로그인</button>
    </form>

    <div class="message-container">
    <%
        String error = request.getParameter("error");
        // msg 변수는 위에서 이미 선언했으므로 재사용하지 않거나, 위쪽 스크립트에서 처리했으므로 여기서는 텍스트만 남겨둡니다.
        
        if ("1".equals(error)) {
    %>
        <p class="error">아이디 또는 비밀번호가 잘못되었습니다.</p>
    <%
        } else if ("session".equals(error)) {
    %>
        <p class="session-error">세션이 만료되었습니다. 다시 로그인해주세요.</p>
    <%
        } else if ("need_login".equals(error)) { 
    %>
        <p class="session-error">게임 이용을 위해 로그인해주세요.</p>
    <%
        } else if ("join_success".equals(msgParam)) {
    %>
        <p class="join-success">회원가입이 완료되었습니다! 로그인해주세요.</p>
    <%
        }
    %>
    </div>

    <form action="<%=request.getContextPath()%>/view/SignUpPage.jsp" method="get" style="margin-top: 20px; text-align: center;">
        <button type="submit" class="submit-btn register-btn">회원가입</button>
    </form>
</div>

</body>
</html>