<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 정보 확인 (MainPage와 동일한 로직)
    String nickname = (String) session.getAttribute("saveName");
    String userID = (String) session.getAttribute("userID");
    Object cashObj = session.getAttribute("cash");
    
    // 캐시가 null이면 0으로 처리 (안전장치)
    int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    
    boolean isLoggedIn = (nickname != null && userID != null);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>자주 묻는 질문 - Cleen Bakara</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=1">
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/QnA.css?v=1">
<!-- 반응형 CSS -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/responsive.css?v=1">

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>

    <div class="navbar-center">
        <a class="nav-link" href="<%=request.getContextPath()%>/mainpage">홈으로</a>
        <% if (isLoggedIn) { %>
            <a class="nav-link" href="<%=request.getContextPath()%>/view/MyInfo.jsp">마이페이지</a>
        <% } %>
        
        <a class="nav-link" href="<%=request.getContextPath()%>/view/QnAPage.jsp" style="color: #004ea2;">고객센터(QnA)</a>
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

<main class="container">
    <div class="qna-accordion-section">
        <h1 class="text-center mb-5" style="color: #2c3e50; font-weight: 800;">자주 묻는 질문 (FAQ)</h1>
    
        <div class="accordion" id="qnaAccordion">
            
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingOne">
                    <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne">
                        Q. 게임 캐시는 어떻게 얻나요?
                    </button>
                </h2>
                <div id="collapseOne" class="accordion-collapse collapse show" data-bs-parent="#qnaAccordion">
                    <div class="accordion-body">
                        가장 기본적인 캐시 획득 방법은 다음과 같습니다:
                        <ul>
                            <li><strong>회원가입 보상:</strong> 회원가입 즉시 <strong>100,000 캐시</strong>가 지급됩니다.</li>
                            <li><strong>일일 로그인 보상:</strong> 매일 첫 로그인 시 <strong>10,000 캐시</strong>가 추가로 지급됩니다.</li>
                            <li><strong>게임 승리:</strong> 사다리나 룰렛 등 게임에서 승리하면 베팅 금액에 배당률을 곱한 만큼 캐시를 획득할 수 있습니다.</li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingTwo">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo">
                        Q. 룰렛 게임의 배당률은 어떻게 되나요?
                    </button>
                </h2>
                <div id="collapseTwo" class="accordion-collapse collapse" data-bs-parent="#qnaAccordion">
                    <div class="accordion-body">
                        룰렛 게임의 배당률은 참가 옵션의 개수와 동일합니다.<br>
                        예를 들어, <strong>과일 옵션이 5개</strong>라면 <strong>배당률은 5배</strong>가 적용되어 승리 시 베팅 금액의 5배(400% 이득)를 얻게 됩니다.
                    </div>
                </div>
            </div>
            
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingThree">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseThree">
                        Q. 비밀번호나 닉네임을 변경하고 싶어요.
                    </button>
                </h2>
                <div id="collapseThree" class="accordion-collapse collapse" data-bs-parent="#qnaAccordion">
                    <div class="accordion-body">
                        로그인 후 상단 네비게이션 바의 <strong>마이페이지</strong> 버튼을 눌러 이동하여 비밀번호와 닉네임을 수정할 수 있습니다.
                    </div>
                </div>
            </div>

             <div class="accordion-item">
                <h2 class="accordion-header" id="headingFour">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseFour">
                        Q. 회원 탈퇴는 어떻게 하나요?
                    </button>
                </h2>
                <div id="collapseFour" class="accordion-collapse collapse" data-bs-parent="#qnaAccordion">
                    <div class="accordion-body">
                        마이페이지 하단에 있는 <strong>회원 탈퇴</strong> 버튼을 통해 진행하실 수 있습니다.<br>
                        탈퇴 시 모든 게임 기록 및 캐시 정보가 삭제됩니다.
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</main>

<footer>
  <p>JSP 과제 | 조영록 | 김종범 | 문건우</p>
</footer>

<!-- Sweet Alert을 이용한 알림창 디자인 영역 -->
<script>
const CONTEXT_PATH = "<%=request.getContextPath()%>";
const IS_LOGGED_IN = <%=isLoggedIn%>;

function confirmLogout() 
{
    Swal.fire
    ({
        title: '로그아웃 하시겠습니까?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#004ea2',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '로그아웃',
        cancelButtonText: '취소'
    }).then((result) => {
        if (result.isConfirmed) {
            location.href = CONTEXT_PATH + "/logout";
        }
    });
}
</script>

</body>
</html>