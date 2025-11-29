/**
 * 파일명: RouletteGame.js
 * 설명: 룰렛 게임의 클라이언트 측 로직을 담당하는 JavaScript 파일입니다.
 *       캔버스에 룰렛 휠을 그리고, 사용자 클릭 이벤트 처리, 룰렛 스핀 애니메이션,
 *       서버(RouletteController)와의 통신, 게임 결과 표시 등 동적인 룰렛 게임 플레이를 관리합니다.
 *
 * 전체 실행 흐름에서의 역할:
 * 1.  `RoulettePage.jsp`가 로드될 때 함께 로드되어 실행됩니다.
 * 2.  페이지 로드 후, `drawRoulette()` 함수를 통해 캔버스에 룰렛 휠을 초기 상태로 그립니다.
 * 3.  사용자가 룰렛 휠을 클릭하면 `handleCanvasClick()` 함수가 호출되어 베팅 유효성을 검사하고,
 *     선택된 세그먼트와 베팅 금액을 `spin()` 함수에 전달합니다.
 * 4.  `spin()` 함수는 선택된 옵션과 베팅 금액을 포함하여 `RouletteController`로 AJAX 요청을 보냅니다.
 * 5.  `RouletteController`로부터 게임 결과(최종 당첨 옵션, 승패 여부, 최종 캐시)를 JSON으로 응답받습니다.
 * 6.  응답받은 데이터를 기반으로 룰렛 휠이 당첨 옵션으로 회전하는 애니메이션(`animate` 함수)을 실행합니다.
 * 7.  애니메이션 완료 후 `alert` 메시지와 함께 최종 결과(승패, 업데이트된 캐시)를 `RoulettePage.jsp`에 표시합니다.
 * 8.  `handleRegenerate()` 함수는 룰렛 과일 개수 변경 시 페이지를 새로고침하여 룰렛을 재구성합니다.
 */
console.log("RouletteGame.js 로드됨 ✅ (v1.1 - Click Fix)");

// --- 전역 변수 선언 ---
const canvas = document.getElementById('roulette-canvas'); // 룰렛을 그릴 캔버스 요소
const ctx = canvas.getContext('2d'); // 캔버스의 2D 렌더링 컨텍스트
const cashDisplay = document.getElementById("my-cash"); // 현재 캐시를 표시하는 DOM 요소
const betInput = document.getElementById("betAmount"); // 베팅 금액 입력 필드
const gameContainer = document.getElementById("game-container"); // 게임 전체 컨테이너 (컨텍스트 경로 접근용)

// JSP에서 동적으로 생성된 options 배열을 사용합니다. (룰렛의 각 섹션에 표시될 항목)
const colors = ["#FF6B6B", "#FAD02E", "#4ECCA3", "#36A2EB", "#FF9F40", "#9966FF", "#FFCD56", "#C9CBCF", "#4BC0C0", "#FF6384"]; // 룰렛 섹션별 색상
const arcSize = (2 * Math.PI) / options.length; // 각 룰렛 섹션의 각도 크기
let currentAngle = 0; // 룰렛의 현재 회전 각도
let isSpinning = false; // 룰렛이 현재 회전 중인지 여부
let selectedSegmentIndex = -1; // 사용자가 선택한 (베팅한) 룰렛 섹션의 인덱스

// --- 함수 정의 ---

/**
 * 캔버스에 룰렛 휠을 그리는 함수.
 * 룰렛의 각 섹션(과일), 색상, 텍스트를 현재 회전 각도에 맞춰 렌더링합니다.
 */
function drawRoulette() {
    const cx = canvas.width / 2; // 캔버스 중앙 X 좌표
    const cy = canvas.height / 2; // 캔버스 중앙 Y 좌표
    const radius = cx - 10; // 룰렛 원의 반지름 (테두리 여백 고려)

    ctx.clearRect(0, 0, canvas.width, canvas.height); // 캔버스 전체 지우기
    ctx.save(); // 현재 캔버스 상태 저장
    ctx.translate(cx, cy); // 원점을 캔버스 중앙으로 이동
    ctx.rotate(currentAngle); // 현재 룰렛 회전 각도 적용
    ctx.translate(-cx, -cy); // 원점 복원
    
    // 각 룰렛 섹션 그리기
    for(let i = 0; i < options.length; i++) {
        const start = i * arcSize; // 섹션 시작 각도
        const end = (i + 1) * arcSize; // 섹션 끝 각도
        
        ctx.beginPath();
        ctx.moveTo(cx, cy); // 원의 중심에서 시작
        ctx.arc(cx, cy, radius, start, end); // 호 그리기
        ctx.fillStyle = colors[i % colors.length]; // 섹션 색상 적용
        ctx.fill(); // 색상 채우기
        ctx.stroke(); // 테두리 그리기
        
        ctx.save(); // 텍스트 회전을 위한 캔버스 상태 저장
        
        // 선택된 섹션(사용자가 베팅한)의 배경색을 변경하여 강조
        if (i === selectedSegmentIndex) {
            ctx.fillStyle = (options[i] === "레몬") ? "red" : "#FFD700"; // 레몬은 특별히 빨강, 외에는 황금색
        } else {
            ctx.fillStyle = "black"; // 기본 텍스트 색상
        }

        ctx.font = "bold 20px Arial"; // 폰트 설정
        ctx.textAlign = "center"; // 텍스트 가로 정렬
        ctx.textBaseline = "middle"; // 텍스트 세로 정렬

        // 텍스트가 룰렛 섹션의 중심에 오도록 각도와 위치 계산
        const textAngle = start + arcSize / 2;
        const tx = cx + Math.cos(textAngle) * (radius * 0.7);
        const ty = cy + Math.sin(textAngle) * (radius * 0.7);
        ctx.translate(tx, ty); // 텍스트 위치로 원점 이동
        ctx.rotate(textAngle + Math.PI / 2); // 텍스트 회전
        ctx.fillText(options[i], 0, 0); // 텍스트 그리기
        ctx.restore(); // 텍스트 회전 전 캔버스 상태 복원
    }
    ctx.restore(); // 룰렛 회전 전 캔버스 상태 복원
}

/**
 * 캔버스 클릭 이벤트를 처리하여 사용자가 어떤 룰렛 섹션에 베팅했는지 감지합니다.
 * 베팅 금액 유효성 검사 후, 확인 메시지를 통해 `spin()` 함수를 호출합니다.
 * @param {Event} event 클릭 이벤트 객체
 */
function handleCanvasClick(event) {
    if (isSpinning) return; // 룰렛 회전 중에는 클릭 무시

    // 캔버스 내에서의 클릭 좌표 계산
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    const x = (event.clientX - rect.left) * scaleX;
    const y = (event.clientY - rect.top) * scaleY;
    
    const cx = canvas.width / 2; // 캔버스 중앙 X
    const cy = canvas.height / 2; // 캔버스 중앙 Y

    // 클릭이 룰렛 원 내부에서 발생했는지 확인
    const dist = Math.sqrt(Math.pow(x - cx, 2) + Math.pow(y - cy, 2));
    if (dist > (cx - 10)) return; // 룰렛 원 바깥 클릭 무시

    // 클릭 지점의 각도를 계산하여 어떤 섹션을 클릭했는지 파악
    let clickAngle = Math.atan2(y - cy, x - cx) - currentAngle;
    while (clickAngle < 0) { clickAngle += 2 * Math.PI; } // 각도를 0 ~ 2*PI 범위로 조정
    clickAngle %= (2 * Math.PI);

    const segmentIndex = Math.floor(clickAngle / arcSize); // 클릭된 섹션의 인덱스
    const selectedFruit = options[segmentIndex]; // 선택된 과일 (베팅 옵션)
    
    selectedSegmentIndex = segmentIndex; // 선택된 섹션 강조를 위해 인덱스 저장
    drawRoulette(); // 선택 강조를 위해 룰렛 다시 그리기

    const bet = betInput.value; // 베팅 금액
    // 베팅 금액 유효성 검사
    if (bet <= 0) {
        alert("베팅 금액을 100원 이상으로 설정해주세요.");
        selectedSegmentIndex = -1; // 선택 강조 해제
        drawRoulette();
        return;
    }

    // 사용자에게 베팅 확인 메시지
    const confirmation = confirm(`"${selectedFruit}"에 ${bet}원을 배팅하시겠습니까?`);
    if (confirmation) {
        spin(selectedFruit, bet); // 확인 시 룰렛 스핀 시작
    } else {
        selectedSegmentIndex = -1; // 취소 시 선택 강조 해제
        drawRoulette();
    }
}

/**
 * 룰렛 스핀 애니메이션을 시작하고, 서버에 게임 결과를 요청합니다.
 * @param {string} pick 사용자가 베팅한 옵션 (과일 이름)
 * @param {number} bet 베팅 금액
 */
function spin(pick, bet) {
    isSpinning = true; // 룰렛 회전 중 상태로 설정
    const contextPath = gameContainer.dataset.contextPath; // 컨텍스트 경로 가져오기
    
    // 서버(RouletteController)에 보낼 파라미터 구성
    const params = new URLSearchParams();
    options.forEach(o => params.append("option", o)); // 모든 룰렛 옵션 전달
    params.append("bet", bet); // 베팅 금액 전달
    params.append("userPick", pick); // 사용자가 선택한 옵션 전달
    
    // 서버에 AJAX 요청을 보냅니다.
    fetch(`${contextPath}/roulette?${params.toString()}`)
        .then(res => res.json()) // JSON 응답 파싱
        .then(data => {
            if (data.error) throw new Error(data.error); // 서버에서 에러가 반환된 경우 처리
            
            // 서버에서 받은 당첨 옵션의 인덱스와 목표 각도를 계산
            const winnerIdx = options.indexOf(data.winner);
            const winnerCenterAngle = (winnerIdx * arcSize) + (arcSize / 2); // 당첨 섹션의 중심 각도
            // 룰렛 포인터가 당첨 섹션을 정확히 가리키도록 목표 회전 각도 계산
            const targetRotation = (1.5 * Math.PI) - winnerCenterAngle; // 1.5 * PI는 포인터의 위치에 해당하는 각도
            const totalRotation = targetRotation + (10 * 2 * Math.PI); // 충분히 많이 회전하도록 10바퀴 추가

            let startTimestamp = null; // 애니메이션 시작 시간
            const duration = 4000; // 애니메이션 지속 시간 (4초)

            /**
             * 룰렛 회전 애니메이션의 각 프레임을 처리하는 함수.
             * `requestAnimationFrame`을 통해 부드러운 애니메이션을 구현합니다.
             * @param {DOMHighResTimeStamp} timestamp 현재 시간
             */
            function animate(timestamp) {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = timestamp - startTimestamp;
                
                if (progress < duration) {
                    // ease-out 효과를 적용하여 회전 속도를 점진적으로 줄입니다.
                    const easeOutRate = 1 - Math.pow(1 - (progress / duration), 3);
                    currentAngle = totalRotation * easeOutRate; // 현재 회전 각도 업데이트
                    drawRoulette(); // 룰렛 다시 그리기
                    requestAnimationFrame(animate); // 다음 프레임 요청
                } else {
                    // 애니메이션 완료 후 최종 각도 설정
                    currentAngle = totalRotation % (2 * Math.PI);
                    drawRoulette();
                    setTimeout(() => {
                        alert(data.message); // 서버에서 받은 게임 결과 메시지 출력
                        if(cashDisplay) {
                            cashDisplay.innerText = data.currentCash.toLocaleString('en-US'); // 업데이트된 캐시 잔액 표시
                        }
                        selectedSegmentIndex = -1; // 선택 강조 해제
                        isSpinning = false; // 회전 상태 해제
                        drawRoulette(); // 최종 상태 룰렛 다시 그리기
                    }, 100);
                }
            }
            requestAnimationFrame(animate); // 애니메이션 시작
        })
        .catch(err => {
            console.error("룰렛 게임 중 오류 발생:", err); // 콘솔에 에러 출력
            alert(err.message || "오류가 발생했습니다. 다시 시도해주세요."); // 사용자에게 에러 메시지 알림
            isSpinning = false; // 회전 상태 해제
            selectedSegmentIndex = -1; // 선택 강조 해제
            drawRoulette(); // 룰렛 초기 상태로 다시 그리기
        });
}

/**
 * "과일 개수" 변경 폼 제출 시 호출됩니다.
 * 새로운 과일 개수의 유효성을 검사하고, 페이지를 새로고침하여 룰렛 게임을 재설정합니다.
 */
function handleRegenerate() {
    const newCountInput = document.getElementById("fruitCountInput"); // 과일 개수 입력 필드
    const newCount = parseInt(newCountInput.value, 10); // 입력된 새 과일 개수 파싱

    // 입력된 과일 개수의 유효성 검사 (2에서 10 사이)
    if (isNaN(newCount) || newCount < 2 || newCount > 10) {
        alert("2에서 10 사이의 올바른 과일 개수를 입력하세요.");
        return;
    }
    const contextPath = gameContainer.dataset.contextPath; // 컨텍스트 경로 가져오기
    // 새로운 과일 개수를 파라미터로 하여 페이지를 새로고침 (JSP가 재로딩되어 룰렛 게임 재구성)
    window.location.href = `${contextPath}/roulette?fruitCount=${newCount}`;
}

// --- 초기화 및 이벤트 리스너 등록 ---
canvas.addEventListener('click', handleCanvasClick); // 캔버스 클릭 시 베팅 처리
document.getElementById("regenerate-form").onsubmit = function(e) {
    e.preventDefault(); // 폼 기본 제출 동작 방지
    handleRegenerate(); // 과일 개수 변경 처리
};
drawRoulette(); // 페이지 로드 시 룰렛 초기 상태 그리기