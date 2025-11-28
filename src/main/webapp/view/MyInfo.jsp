<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.MemberDAO" %>
<%@ page import="model.Member" %>
<%
    // 로그인 체크
    String sessionID = (String) session.getAttribute("userID");
    if (sessionID == null) {
        response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
        return;
    }
    
    // DB에서 최신 정보 가져오기
    MemberDAO dao = new MemberDAO();
    Member member = dao.findMemberByID(sessionID);
    if (member == null) {
        response.sendRedirect(request.getContextPath() + "/logout");
        return;
    }
    
    // Navbar용 변수
    String nickname = member.getNickname();
    int currentCash = member.getCash();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마이페이지 - Cleen Bakara</title>
<!-- 부트스트랩 (레이아웃용) -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- 공통 CSS -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=1">
<!-- 박스 디자인 (SimpleCommon.css) -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/SimpleCommon.css?v=1">
<!-- 알림창 디자인 전용 CSS -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- 상단 내비게이션 바(메인 페이지와 동일) -->
<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>
    <div class="navbar-center">
        <a class="nav-link" href="<%=request.getContextPath()%>/mainpage">홈으로</a>
        <!-- 마이페이지 강조 -->
        <a class="nav-link" href="<%=request.getContextPath()%>/view/MyInfo.jsp" style="color: #004ea2;">마이페이지</a>
        <a class="nav-link" href="<%=request.getContextPath()%>/view/QnAPage.jsp">고객센터(QnA)</a>
    </div>
    <div class="navbar-right">
        <div class="user-info">
            <div>반갑습니다, <strong><%= nickname %></strong>님</div>
            <div class="user-cash"><%= String.format("%,d", currentCash) %> 원</div>
        </div>
        <a class="auth-btn logout-btn" href="#" onclick="confirmLogout()">로그아웃</a>
    </div>
</nav>

<!-- 내 정보 박스 -->
<div class="info-container">
    <div class="info-header">
        <h2>내 정보 수정</h2>
        <p>회원 정보를 안전하게 관리하세요.</p>
    </div>

    <form action="<%=request.getContextPath()%>/updateMember" method="post">
        <div class="form-group">
            <label>아이디</label>
            <input type="text" value="<%= member.getUserID() %>" readonly>
        </div>

        <div class="form-group">
            <label>보유 캐시</label>
            <input type="text" value="<%= String.format("%,d", member.getCash()) %> 원" readonly style="color: #f39c12; font-weight: bold;">
        </div>

        <div class="form-group">
            <label>닉네임</label>
            <input type="text" name="nickname" value="<%= member.getNickname() %>" required>
        </div>
        
        <div class="form-group">
            <label>비밀번호</label>
            <input type="password" name="userPW" value="<%= member.getUserPW() %>" required>
        </div>

        <div class="btn-group">
            <button type="submit" class="update-btn">정보 수정하기</button>
            <button type="button" class="btn-delete" onclick="confirmDelete()">회원 탈퇴</button>
        </div>
    </form>
    
    <!-- 탈퇴용 히든 폼 -->
    <form id="deleteForm" action="<%=request.getContextPath()%>/deleteMember" method="post" style="display:none;"></form>
</div>

<footer>
    <p>JSP과제 | 조영록 | 김종범 | 문건우</p>
</footer>

<!-- Sweet Alert을 이용한 알림창 디자인 영역 -->
<script>
const CONTEXT_PATH = "<%=request.getContextPath()%>";

function confirmLogout() 
{
    Swal.fire
    ({
        title: '로그아웃',
        text: '정말 로그아웃 하시겠습니까?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#004ea2',
        cancelButtonColor: '#d33',
        confirmButtonText: '로그아웃',
        cancelButtonText: '취소'
    }).then((result) => {
        if (result.isConfirmed) location.href = CONTEXT_PATH + "/logout";
    });
}

function confirmDelete() 
{
    Swal.fire
    ({
        title: '회원 탈퇴',
        text: '정말 탈퇴하시겠습니까? 모든 캐시 정보가 삭제됩니다.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#aaa',
        confirmButtonText: '탈퇴하기',
        cancelButtonText: '취소'
    }).then((result) => {
        if (result.isConfirmed) document.getElementById("deleteForm").submit();
    });
}
</script>

</body>
</html>