<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 - Cleen Bakara</title>
<!-- 1. 공통 레이아웃 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=1">
<!-- 2. 박스 디자인 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/SimpleCommon.css?v=1">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- 클라이언트 측 유효성 검사 -->
<!-- 보안에 취약하지만, SignUpController.java에서는 서버 측 검사를 해주고 있음 -->
<script>
function validateForm() 
{
    const id = document.getElementById("userID").value;
    const pw = document.getElementById("userPW").value;
    const nick = document.getElementById("nickname").value;

    const idRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{4,16}$/;
    if (!idRegex.test(id)) 
    {
        Swal.fire('입력 오류', '아이디는 영문 포함 4~16자여야 합니다.', 'warning');
        return false;
    }

    const pwRegex = /^(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{6,20}$/;
    if (!pwRegex.test(pw)) 
    {
        Swal.fire('입력 오류', '비밀번호는 특수문자 포함 6~20자여야 합니다.', 'warning');
        return false;
    }

    const nickRegex = /^[a-zA-Z가-힣]{2,12}$/;
    if (!nickRegex.test(nick)) 
    {
        Swal.fire('입력 오류', '별명은 한글 또는 영문 2~12자여야 합니다.', 'warning');
        return false;
    }
    return true;
}
</script>
</head>
<body>

<!-- 1. 심플 내비게이션 바 (로고만) -->
<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>
</nav>

<!-- 2. 회원가입 박스 -->
<div class="auth-container">
    <h2 class="auth-title">회원가입</h2>

    <form action="<%=request.getContextPath()%>/signup" method="post" onsubmit="return validateForm()">
        <div class="input-group">
            <input type="text" name="userID" id="userID" placeholder="아이디 (영문 포함 4~16자)" required>
        </div>
        
        <div class="input-group">
            <input type="password" name="userPW" id="userPW" placeholder="비밀번호 (특수문자 필수 6~20자)" required>
        </div>
        
        <div class="input-group">
            <input type="text" name="nickname" id="nickname" placeholder="별명 (한글/영문 2~12자)" required>
        </div>
        
        <input type="submit" value="회원가입" class="submit-btn">
    </form>
</div>

<footer>
    <p>JSP과제 | 조영록 | 김종범 | 문건우</p>
</footer>

<%
    String error = request.getParameter("error");
    if ("validation".equals(error)) {
%>
    <script>Swal.fire('오류', '입력 형식이 올바르지 않거나 중복된 아이디입니다.', 'error');</script>
<%
    }
%>

</body>
</html>