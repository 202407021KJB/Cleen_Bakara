<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인 - Cleen Bakara</title>
<!-- 1. 공통 레이아웃 (배경, 상단바 틀) -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=1">
<!-- 2. 박스 디자인 (SimpleCommon.css) -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/SimpleCommon.css?v=1">
<!-- 3. 예쁜 알림창 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<%
    String msgParam = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!-- 1. 심플 내비게이션 바 (로고만 표시) -->
<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>
</nav>

<!-- 2. 로그인 박스 -->
<div class="auth-container">
    <h2 class="auth-title">로그인</h2>

    <form action="<%=request.getContextPath()%>/login" method="post">
        <div class="input-group">
            <input type="text" name="userID" placeholder="아이디" required>
        </div>
        <div class="input-group">
            <input type="password" name="userPW" placeholder="비밀번호" required>
        </div>
        <button type="submit" class="submit-btn">로그인</button>
    </form>

    <a href="<%=request.getContextPath()%>/view/SignUpPage.jsp" class="register-link">
        아직 계정이 없으신가요? <strong>회원가입</strong>
    </a>
</div>

<footer>
    <p>JSP과제 | 조영록 | 김종범 | 문건우</p>
</footer>

<!-- 3. 알림 스크립트 (SweetAlert2) -->
<script>
    const msg = "<%= (msgParam != null) ? msgParam : "" %>";
    const err = "<%= (error != null) ? error : "" %>";

    if (msg === "join_success") {
        Swal.fire({
            title: '가입 완료!',
            text: '회원가입을 축하합니다! 보너스 10만 캐시가 지급되었습니다.',
            icon: 'success',
            confirmButtonColor: '#004ea2'
        });
    }

    if (err === "1") {
        Swal.fire({
            title: '로그인 실패',
            text: '아이디 또는 비밀번호가 일치하지 않습니다.',
            icon: 'error',
            confirmButtonColor: '#d33'
        });
    } else if (err === "session") {
        Swal.fire('세션 만료', '다시 로그인해주세요.', 'warning');
    } else if (err === "need_login") {
        Swal.fire('로그인 필요', '게임 이용을 위해 로그인이 필요합니다.', 'warning');
    }
</script>

</body>
</html>