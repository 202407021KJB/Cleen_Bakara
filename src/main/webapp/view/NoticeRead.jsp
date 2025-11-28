<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 로그인 세션 확인
    String nickname = (String) session.getAttribute("saveName");
    String userID = (String) session.getAttribute("userID");
    Object cashObj = session.getAttribute("cash");
    int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    boolean isLoggedIn = (nickname != null && userID != null);

    // 파라미터로 글 번호(id) 받기
    String id = request.getParameter("id");
    
    // (임시) DB 대신 화면에 보여줄 더미 데이터 설정
    String title = "제목 없음";
    String date = "2025.11.28";
    String writer = "운영자";
    String content = "내용을 불러올 수 없습니다.";

    if ("5".equals(id)) {
        title = "[점검] 11월 정기 서버 점검 안내";
        date = "2025.11.27";
        content = "안녕하세요, Cleen Bakara입니다.<br><br>안정적인 서비스 제공을 위해 정기 점검이 진행될 예정입니다.<br>점검 시간 동안은 게임 이용이 제한되오니 양해 부탁드립니다.<br><br>- 일시: 2025년 11월 29일 03:00 ~ 05:00 (2시간)<br>- 내용: 서버 안정화 및 보안 업데이트";
    } else if ("4".equals(id)) {
        title = "[이벤트] 신규 가입자 10만 캐시 지급!";
        date = "2025.11.26";
        writer = "GM바카라";
        content = "환영합니다! <br><br>지금 가입하시는 모든 분들께 <strong>100,000 캐시</strong>를 즉시 지급해 드립니다.<br>친구들에게도 Cleen Bakara를 소개해주세요!<br><br>* 가입 즉시 자동으로 지급됩니다.";
    } else if ("3".equals(id)) {
        title = "[안내] 불법 프로그램 사용 제재 명단";
        date = "2025.11.20";
        content = "공정한 게임 환경을 위해 불법 프로그램 사용자를 단속하였습니다.<br><br><strong>[영구 이용 제한]</strong><br>user1***<br>hack***<br>abcd***<br><br>앞으로도 클린한 게임 문화를 위해 노력하겠습니다.";
    } else if ("2".equals(id)) {
        title = "룰렛 게임 배당률 상향 조정 안내";
        date = "2025.11.15";
        writer = "개발팀";
        content = "유저분들의 건의사항을 반영하여 룰렛 게임의 배당률 시스템을 개선하였습니다.<br><br>기존: 고정 배당<br>변경: <strong>선택지 개수에 비례한 배당 (최대 10배!)</strong><br><br>더욱 짜릿해진 룰렛을 지금 바로 경험해보세요.";
    } else {
        // 그 외 번호
        title = "공지사항 상세 내용";
        content = "선택하신 게시글의 내용을 확인할 수 있습니다.<br>이 페이지는 NoticeRead.jsp에서 처리됩니다.";
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= title %> - Cleen Bakara</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- 공통 레이아웃 + 게시판 스타일 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=2">
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Notice.css?v=1">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- 상단 내비게이션 바 -->
<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>
    <div class="navbar-center">
        <a class="nav-link" href="<%=request.getContextPath()%>/mainpage">홈으로</a>
        <% if (isLoggedIn) { %>
            <a class="nav-link" href="<%=request.getContextPath()%>/view/MyInfo.jsp">마이페이지</a>
        <% } %>
        <a class="nav-link" href="<%=request.getContextPath()%>/view/QnAPage.jsp">고객센터(QnA)</a>
    </div>
    <div class="navbar-right">
        <% if (isLoggedIn) { %>
            <div class="user-info">
                <div>반갑습니다, <strong><%= nickname %></strong>님</div>
                <div class="user-cash"><%= String.format("%,d", currentCash) %> 원</div>
            </div>
            <a class="auth-btn logout-btn" href="#" onclick="confirmLogout()">로그아웃</a>
        <% } else { %>
            <a class="auth-btn" href="<%=request.getContextPath()%>/view/LoginPage.jsp">로그인</a>
            <a class="auth-btn logout-btn" href="<%=request.getContextPath()%>/view/SignUpPage.jsp">회원가입</a>
        <% } %>
    </div>
</nav>

<!-- 상세 내용 보기 -->
<div class="notice-container">
    <div class="read-header">
        <div class="read-title"><%= title %></div>
        <div class="read-meta">
            <span>작성자: <%= writer %></span>
            <span>작성일: <%= date %></span>
        </div>
    </div>

    <div class="read-content">
        <%= content %>
    </div>

    <div style="text-align: center;">
        <a href="<%=request.getContextPath()%>/view/NoticePage.jsp" class="btn-list">목록으로 돌아가기</a>
    </div>
</div>

<footer>
    <p>JSP과제 | 조영록 | 김종범 | 문건우</p>
</footer>

<script>
const CONTEXT_PATH = "<%=request.getContextPath()%>";
function confirmLogout() {
    Swal.fire({
        title: '로그아웃 하시겠습니까?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#004ea2',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '로그아웃',
        cancelButtonText: '취소'
    }).then((result) => {
        if (result.isConfirmed) location.href = CONTEXT_PATH + "/logout";
    });
}
</script>

</body>
</html>