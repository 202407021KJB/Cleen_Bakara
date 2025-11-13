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
    const id = document.getElementById("userId").value;
    const pw = document.getElementById("passwd").value;
    const nick = document.getElementById("nickname").value;

    // 아이디: 영문자(소문자 또는 대문자) 필수
    const idRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{4,16}$/;
    if (!idRegex.test(id))
    {
        alert("아이디는 영문자를 포함한 4~16자의 영문자/숫자 조합이어야 합니다.");
        return false;
    }

    // 비밀번호: 특수문자 최소 1개 포함
    const pwRegex = /^(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{6,20}$/;
    if (!pwRegex.test(pw))
    {
        alert("비밀번호는 6~20자이며, 특수문자를 최소 1개 포함해야 합니다.");
        return false;
    }

    // 별명: 특수문자 X, 한글 또는 영문만
    const nickRegex = /^[a-zA-Z가-힣]{2,12}$/;
    if (!nickRegex.test(nick))
    {
        alert("별명은 한글 또는 영문만 사용 가능합니다. (특수문자 X)");
        return false;
    }

    return true;
}
</script>
</head>

<body>
<form action="<%=request.getContextPath()%>/join" method="post" onsubmit="return validateForm();">
    <label>아이디:</label>
    <input type="text" name="userId" id="userId" required><br>

    <label>비밀번호:</label>
    <input type="password" name="passwd" id="passwd" required><br>

    <label>별명:</label>
    <input type="text" name="nickname" id="nickname" required><br>

    <button type="submit">회원가입</button>
</form>
</body>
</html>