<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.MemberDAO" %>
<%@ page import="model.Member" %>
<%
    // 세션 체크 및 회원 정보 로드
    String userID = (String) session.getAttribute("userID");
    if (userID == null) {
        response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
        return;
    }
    
    // 최신 회원 정보 가져오기 (캐시, 정보 수정 반영 확인용)
    MemberDAO dao = new MemberDAO();
    Member member = dao.findMemberByID(userID);
    if (member == null) { // 오류 상황
        response.sendRedirect(request.getContextPath() + "/logout");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>마이페이지 - Cleen Bakara</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/MyInfo.css">
<script>
    const CONTEXT_PATH = "<%=request.getContextPath()%>";
    function confirmLogout() {
        if (confirm("정말 로그아웃 하시겠습니까?")) {
            location.href = CONTEXT_PATH + "/logout";
        }
    }
    
    function confirmDelete() {
        if (confirm("정말 탈퇴하시겠습니까?\n탈퇴 시 모든 정보와 캐시가 삭제됩니다.")) {
            // 탈퇴 처리를 위한 폼 제출
            document.getElementById("deleteForm").submit();
        }
    }
</script>
</head>
<body>

<nav class="navbar">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">🎮 Cleen Bakara</a>
    
    <ul class="navbar-nav">
        <li class="nav-item">
          <a class="menu-btn" href="<%=request.getContextPath()%>/mainpage">홈으로</a>
        </li>
        <li class="nav-item">
          <a class="menu-btn" href="#" onclick="confirmLogout()">로그아웃</a>
        </li>
    </ul>
  </div>
</nav>

<div class="info-container">
    <h2>내 정보 수정</h2>

    <form action="<%=request.getContextPath()%>/updateMember" method="post">
        <div class="input-group">
            <label>아이디</label>
            <input type="text" value="<%= member.getUserID() %>" readonly>
        </div>

        <div class="input-group">
            <label>보유 캐시</label>
            <input type="text" value="<%= String.format("%,d", member.getCash()) %> 원" readonly style="color: #e67e22; font-weight: bold;">
        </div>

        <div class="input-group">
            <label>닉네임</label>
            <input type="text" name="nickname" value="<%= member.getNickname() %>" required>
        </div>
        
        <div class="input-group">
            <label>비밀번호</label>
            <input type="password" name="userPW" value="<%= member.getUserPW() %>" required>
        </div>

        <div class="action-btns">
            <button type="submit" class="update-btn">정보 수정</button>
            <button type="button" class="delete-btn" onclick="confirmDelete()">회원 탈퇴</button>
        </div>
    </form>
    
    <form id="deleteForm" action="<%=request.getContextPath()%>/deleteMember" method="post" style="display:none;"></form>
</div>

</body>
</html>