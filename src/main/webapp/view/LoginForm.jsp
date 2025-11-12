<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
</head>
<body>

<h2>로그인 페이지</h2>

<form action="<%=request.getContextPath()%>/login" method="post">
    아이디: <input type="text" name="userId" required><br>
    비밀번호: <input type="password" name="passwd" required><br>
    <button type="submit">로그인</button>
</form>

<%
    String error = request.getParameter("error");
    if ("1".equals(error)) {
%>
    <p style="color:red;">아이디 또는 비밀번호가 잘못되었습니다.</p>
<%
    } else if ("session".equals(error)) {
%>
    <p style="color:orange;">세션이 만료되었습니다. 다시 로그인해주세요.</p>
<%
    }
%>

<!-- ✅ 회원가입 버튼 추가 -->
<form action="<%=request.getContextPath()%>/view/JoinForm.jsp" method="get">
    <button type="submit">회원가입</button>
</form>

</body>
</html>