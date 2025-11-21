<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 - Cleen Bakara</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/SignUpPage.css">

<script>
function validateForm()
{
    const id = document.getElementById("userID").value; [cite_start]// [cite: 8]
    const pw = document.getElementById("userPW").value; [cite_start]// [cite: 8]
    const nick = document.getElementById("nickname").value;

    // 아이디 유효성 검사
    const idRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{4,16}$/; [cite_start]// [cite: 9]
    if (!idRegex.test(id))
    {
        alert("아이디는 영문자를 포함한 4~16자의 영문자/숫자 조합이어야 합니다."); [cite_start]// [cite: 10]
        return false; [cite_start]// [cite: 10]
    }

    // 비밀번호 유효성 검사
    const pwRegex = /^(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{6,20}$/; [cite_start]// [cite: 11]
    if (!pwRegex.test(pw))
    {
        alert("비밀번호는 6~20자이며, 특수문자를 최소 1개 포함해야 합니다."); [cite_start]// [cite: 12]
        return false; [cite_start]// [cite: 12]
    }

    // 별명 유효성 검사
    const nickRegex = /^[a-zA-Z가-힣]{2,12}$/; [cite_start]// [cite: 13]
    if (!nickRegex.test(nick))
    {
        alert("별명은 한글 또는 영문만 가능합니다.");
        return false; [cite_start]// [cite: 14]
    }
    return true;
}
</script>
</head>
<body>

<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">🎮 Cleen Bakara</a>
</nav>

<div class="form-container">
    <h2>회원가입</h2>

    <form action="<%=request.getContextPath()%>/signup" method="post" onsubmit="return validateForm()">
        <div class="input-group">
            <input type="text" name="userID" id="userID" placeholder="아이디 (4~16자, 영문 필수)" required>
        </div>
        
        <div class="input-group">
            <input type="password" name="userPW" id="userPW" placeholder="비밀번호 (6~20자, 특수문자 필수)" required>
        </div>
        
        <div class="input-group">
            <input type="text" name="nickname" id="nickname" placeholder="별명 (2~12자, 한글/영문만)" required>
        </div>
        
        <input type="submit" value="회원가입" class="submit-btn">
    </form>
    
    <div class="message-container">
    <%
        String error = request.getParameter("error");
        if ("validation".equals(error)) {
    %>
        <p class="error">입력 형식이 올바르지 않습니다. 다시 확인해주세요.</p>
    <%
        }
    %>
    </div>

</div>
</body>
</html>