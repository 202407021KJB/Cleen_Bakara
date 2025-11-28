<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 로그인 세션 확인 (Navbar용)
    String nickname = (String) session.getAttribute("saveName");
    String userID = (String) session.getAttribute("userID");
    Object cashObj = session.getAttribute("cash");
    int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    boolean isLoggedIn = (nickname != null && userID != null);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>공지사항 - Cleen Bakara</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- 공통 레이아웃 + 게시판 전용 스타일 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=2">
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Notice.css?v=1">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- 1. 상단 내비게이션 바 (메인과 동일) -->
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

<!-- 2. 공지사항 목록 -->
<div class="notice-container">
    <div class="notice-header">
        <h2>📢 공지사항</h2>
        <p>Cleen Bakara의 새로운 소식과 이벤트를 확인하세요.</p>
    </div>

    <table class="notice-table">
        <thead>
            <tr>
                <th width="10%">번호</th>
                <th class="title-col">제목</th>
                <th width="15%">작성자</th>
                <th width="15%">작성일</th>
            </tr>
        </thead>
        <tbody>
            <!-- 게시글 클릭 시 NoticeRead.jsp로 이동 (id 파라미터 전달) -->
            <tr class="notice-row" onclick="location.href='<%=request.getContextPath()%>/view/NoticeRead.jsp?id=5'">
                <td>5</td>
                <td class="title-col"><span class="notice-badge">점검</span> 11월 정기 서버 점검 안내</td>
                <td>운영자</td>
                <td>2025.11.27</td>
            </tr>
            <tr class="notice-row" onclick="location.href='<%=request.getContextPath()%>/view/NoticeRead.jsp?id=4'">
                <td>4</td>
                <td class="title-col"><span class="notice-badge">이벤트</span> 신규 가입자 10만 캐시 지급!</td>
                <td>GM바카라</td>
                <td>2025.11.26</td>
            </tr>
            <tr class="notice-row" onclick="location.href='<%=request.getContextPath()%>/view/NoticeRead.jsp?id=3'">
                <td>3</td>
                <td class="title-col"><span class="notice-badge">안내</span> 불법 프로그램 사용 제재 명단</td>
                <td>운영자</td>
                <td>2025.11.20</td>
            </tr>
            <tr class="notice-row" onclick="location.href='<%=request.getContextPath()%>/view/NoticeRead.jsp?id=2'">
                <td>2</td>
                <td class="title-col">룰렛 게임 배당률 상향 조정 안내</td>
                <td>개발팀</td>
                <td>2025.11.15</td>
            </tr>
            <tr class="notice-row" onclick="location.href='<%=request.getContextPath()%>/view/NoticeRead.jsp?id=1'">
                <td>1</td>
                <td class="title-col">개인정보 처리방침 변경 안내</td>
                <td>관리자</td>
                <td>2025.11.01</td>
            </tr>
        </tbody>
    </table>
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