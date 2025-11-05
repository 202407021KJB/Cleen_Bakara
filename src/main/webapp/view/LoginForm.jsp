<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<form action = "LoginController.java" method = "post">
		아이디 : <input type = "text" name = "userId" required><br>
		비밀번호 : <input type = "password" name = "passwd" required><br>
		<button type = "submit">로그인</button> 
	</form>
</body>
</html>