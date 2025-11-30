<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>로그인</title>
<!-- 공통 CSS -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=1">
<!-- 메인 페이지와 달리 로그인 창은 상단 바에 로고만 들어있으면 되니, SimpleCommon.css 사용 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/SimpleCommon.css?v=1">
<!-- 반응형 CSS -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/responsive.css?v=1">
<!-- 알림창 디자인 전용 CSS -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<%
    String msgParam = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!-- 로그인 창에서는 상단 바에 로고만 표시 -->
<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>
</nav>

<!-- 로그인 박스 -->
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

<!-- Sweet Alert을 이용한 알림창 디자인 영역 -->
<script>
	/** 조건에 따른 alert 창 띄워주기 로직
	 *  Controller에서 View로 전달할 때, 주소 뒤에 꼬리표를 붙여서 보냄
	 *  여기에서는 가입 성공했을 때, 실패했을 때, 로그인 필요, 세션 만료했을 때로 구분
	 */
    const msg = "<%= (msgParam != null) ? msgParam : "" %>";
    const err = "<%= (error != null) ? error : "" %>";

    /* 여기부터 상황별로 알림을 띄워주는 부분 */
    
    // 가입 성공시
    if (msg === "join_success") 
    {
        Swal.fire
        ({
            title: '가입 완료!',
            text: '회원가입을 축하합니다! 보너스 10만 캐시가 지급되었습니다.',
            icon: 'success',
            confirmButtonColor: '#004ea2'
        });
    }

    // 로그인 실패시
    if (err === "1") 
    {
        Swal.fire
        ({
            title: '로그인 실패',
            text: '아이디 또는 비밀번호가 일치하지 않습니다.',
            icon: 'error',
            confirmButtonColor: '#d33'
        });
    } 
    // 세션 만료시
    else if (err === "session") 
    {
        Swal.fire('세션 만료', '다시 로그인해주세요.', 'warning');
    } 
    // 로그인 필요시
    else if (err === "need_login") 
    {
        Swal.fire('로그인 필요', '게임 이용을 위해 로그인이 필요합니다.', 'warning');
    }
</script>

</body>
</html>