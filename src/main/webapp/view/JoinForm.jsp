<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>

<script>
function validateForm()
{
    const id = document.getElementById("userID").value;
    const pw = document.getElementById("userPW").value;
    const nick = document.getElementById("nickname").value;

    // 유효성 검사
    const idRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{4,16}$/;
    if (!idRegex.test(id))
    {
        alert("아이디는 영문자를 포함한 4~16자의 영문자/숫자 조합이어야 합니다.");
        return false;
    }

    const pwRegex = /^(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{6,20}$/;
    if (!pwRegex.test(pw))
    {
        alert("비밀번호는 6~20자이며, 특수문자를 최소 1개 포함해야 합니다.");
        return false;
    }

    const nickRegex = /^[a-zA-Z가-힣]{2,12}$/;
    if (!nickRegex.test(nick))
    {
        alert("별명은 한글 또는 영문만 가능합니다.");
        return false;
    }
    return true;
}
</script>
</head>
<body>

<h2>회원가입</h2>

<form action="<%=request.getContextPath()%>/join" method="post" onsubmit="return validateForm()">
    아이디: <input type="text" name="userId" id="userID"><br>
    비밀번호: <input type="password" name="passwd" id="userPW"><br>
    별명: <input type="text" name="nickname" id="nickname"><br>
    <input type="submit" value="회원가입">
</form>

</body>
</html>