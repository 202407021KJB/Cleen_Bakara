<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 페이지</title>
</head>
<body>
	<form action="<%=request.getContextPath()%>/join" method="post">
		아이디 : <input type = "text" name = "userId" required><br>
		비밀번호 : <input type = "password" name = "passwd" required><br>
		<button type = "submit">회원가입</button>
	</form>
</body>
</html>