<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- 로그인 여부 확인 -->
<%
	// 세션에서 닉네임, 아이디, 캐시 꺼냄
    String nickname = (String) session.getAttribute("saveName");
    String userID = (String) session.getAttribute("userID");
    Object cashObj = session.getAttribute("cash");
    
    // 캐시가 있다면 숫자로 변환, 없으면 NULL 처리(안전하게)
    int currentCash = (cashObj != null) ? (Integer) cashObj : 0;
    
    // 닉네임과 아이디가 둘 다 있다 -> 로그인
    // 			  하나라도 없다 -> 비로그인
    boolean isLoggedIn = (nickname != null && userID != null);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Cleen Bakara</title>
<!-- 부트스트랩 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- 공통 CSS 및 메인 페이지 전용 CSS -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/Layout.css?v=1">
<link rel="stylesheet" href="<%=request.getContextPath()%>/view/css/MainPage.css?v=1">
<!-- 부트스트랩 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- 알림창 디자인 전용 CSS -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- 상단 내비게이션 바 -->
<nav class="navbar">
    <a class="navbar-brand" href="<%=request.getContextPath()%>/mainpage">
        🎮 Cleen Bakara
    </a>

    <div class="navbar-center">
        <a class="nav-link" onclick="scrollToGame()">게임참여</a>
        
        <!-- 로그인이 되었다면 마이페이지가 보이고, 안했으면 안보임 -->
        <% if (isLoggedIn) { %>
            <a class="nav-link" href="<%=request.getContextPath()%>/view/MyInfo.jsp">마이페이지</a>
        <% } %>
        
        <a class="nav-link" href="<%=request.getContextPath()%>/view/QnAPage.jsp">고객센터(QnA)</a>
    </div>

    <div class="navbar-right">
    <!-- 로그인된 사용자는 별명과 함께 현재 갖고있는 캐시가 출력됨 -->
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

<!-- 메인 배너(캐러셀) -->
<div id="gameCarousel" class="carousel slide" data-bs-ride="carousel">
    <div class="carousel-indicators">
        <button type="button" data-bs-target="#gameCarousel" data-bs-slide-to="0" class="active"></button>
        <button type="button" data-bs-target="#gameCarousel" data-bs-slide-to="1"></button>
    </div>
    <div class="carousel-inner">
        <div class="carousel-item active">
            <a href="#" onclick="checkLoginAndOpenModal('ladderModal')">
                <img src="<%=request.getContextPath()%>/view/img/LadderImg.png" class="d-block w-100" alt="사다리 게임">
            </a>
            <div class="carousel-caption">
                <h3>🪜 사다리 타기</h3>
                <p>당신의 선택이 운명을 결정합니다.</p>
            </div>
        </div>
        <div class="carousel-item">
            <a href="#" onclick="checkLoginAndOpenModal('rouletteModal')">
                <img src="<%=request.getContextPath()%>/view/img/RouletteImg.png" class="d-block w-100" alt="룰렛 게임">
            </a>
            <div class="carousel-caption">
                <h3>🎡 행운의 룰렛</h3>
                <p>돌려라! 대박의 기회!</p>
            </div>
        </div>
    </div>
    <button class="carousel-control-prev" type="button" data-bs-target="#gameCarousel" data-bs-slide="prev">
        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
    </button>
    <button class="carousel-control-next" type="button" data-bs-target="#gameCarousel" data-bs-slide="next">
        <span class="carousel-control-next-icon" aria-hidden="true"></span>
    </button>
</div>

<!-- 하단 콘텐츠 영역 -->
<div class="content-wrapper">
    
    <!-- 좌측 공지사항 -->
    <div class="board-section">
        <div class="section-header">
            <span class="section-title">📢 공지사항</span>
            <a href="<%=request.getContextPath()%>/view/NoticePage.jsp" class="more-btn">더보기 +</a>
        </div>
        <ul class="board-list">
            <li onclick="location.href='<%=request.getContextPath()%>/view/NoticePage.jsp'">
                <span>[점검] 11월 정기 서버 점검 안내</span>
                <span class="date">2025.11.27</span>
            </li>
            <li onclick="location.href='<%=request.getContextPath()%>/view/NoticePage.jsp'">
                <span>[이벤트] 신규 가입자 10만 캐시 지급!</span>
                <span class="date">2025.11.26</span>
            </li>
            <li>
                <span>[안내] 불법 프로그램 사용 제재 명단</span>
                <span class="date">2025.11.20</span>
            </li>
            <li>
                <span>[업데이트] 룰렛 게임 배당률 상향 조정</span>
                <span class="date">2025.11.15</span>
            </li>
        </ul>
    </div>

    <!-- 우측 고객센터 -->
    <div class="board-section" style="background: #f8f9fa;">
        <div class="qna-banner">
            <h3 style="font-weight:bold; margin-bottom:10px;">❓ 고객센터</h3>
            <p class="qna-text">게임 이용 중 궁금한 점이 있으신가요?<br>자주 묻는 질문을 확인해보세요.</p>
            <a href="<%=request.getContextPath()%>/view/QnAPage.jsp" class="qna-btn">1:1 문의 / QnA 바로가기</a>
            <div style="margin-top: 20px; font-size: 24px; font-weight: 900; color: #004ea2;">
                📞 1588 - 0000
            </div>
        </div>
    </div>

</div>

<!-- 사다리와 룰렛의 배너를 각각 클릭하면, 얼마나 배팅할건지 창이 뜨게 됨 -->
<div class="modal fade" id="ladderModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">🪜 사다리 게임 설정</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <form id="ladderSetupForm" action="<%=request.getContextPath()%>/view/LadderPage.jsp" method="GET">
           <div class="mb-3">
            <label class="form-label">동물 마리 수 (2~10):</label>
            <input type="number" class="form-control" name="animalCount" min="2" max="10" value="3" required>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button type="submit" form="ladderSetupForm" class="btn btn-primary">게임 시작</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="rouletteModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">🎡 룰렛 게임 설정</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <form id="rouletteSetupForm" action="<%=request.getContextPath()%>/roulette" method="GET">
          <div class="mb-3">
             <label class="form-label">과일 개수 (2~10):</label>
            <input type="number" class="form-control" name="fruitCount" min="2" max="10" value="2" required>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button type="submit" form="rouletteSetupForm" class="btn btn-primary">게임 시작</button>
      </div>
    </div>
  </div>
</div>

<footer>
 <p>JSP과제 | 조영록 | 김종범 | 문건우</p>
</footer>

<!-- 일일 보상 및 알림 메시지 확인 스크립트 -->
<%
    // 세션에 alertMsg가 있는지 확인하는 부분
    String alertMsg = (String) session.getAttribute("alertMsg");
    if (alertMsg != null) 
    {
    	// 새로고침 했을때 또 뜨지 않게 바로 삭제
        session.removeAttribute("alertMsg");
%>
    <script>
        document.addEventListener("DOMContentLoaded", function() 
        {

            Swal.fire
            ({
                title: '🎁 출석 보상 지급!',
                text: '<%= alertMsg %>',
                icon: 'success',
                confirmButtonColor: '#004ea2',
                confirmButtonText: '감사합니다!'
            });
        });
    </script>
<%
    }
%>

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
        if (result.isConfirmed) 
        {
            location.href = CONTEXT_PATH + "/logout";
        }
    });
}

function checkLoginAndOpenModal(modalId) 
{
    if (!IS_LOGGED_IN) 
    {
        Swal.fire
        ({
            title: '로그인이 필요합니다',
            text: '게임을 이용하시려면 먼저 로그인해주세요.',
            icon: 'warning',
            confirmButtonColor: '#004ea2',
            confirmButtonText: '로그인 하러가기'
        }).then((result) => {
            if (result.isConfirmed) 
            {
                location.href = CONTEXT_PATH + "/view/LoginPage.jsp";
            }
        });
    } 
    else 
    {
        const gameModal = new bootstrap.Modal(document.getElementById(modalId));
        gameModal.show();
    }
}

function scrollToGame() 
{
    document.getElementById('gameCarousel').scrollIntoView({ behavior: 'smooth' });
}
</script>
</body>
</html>