console.log("roulette.js 로드됨 ✅ (v2.0 검증된 로직 적용)");

/**
 * @file roulette.js
 * 룰렛 게임의 클라이언트 사이드 로직을 담당합니다.
 * '돌리기' 버튼 클릭 시 서버에 당첨 결과를 요청하고,
 * 그 결과를 바탕으로 룰렛을 회전시키는 애니메이션을 보여줍니다.
 */

// --- 1. 전역 변수 및 DOM 요소 초기화 ---

const spinBtn = document.getElementById('spin-btn');
const canvas = document.getElementById('roulette-canvas');
const ctx = canvas.getContext('2d');
const gameContainer = document.getElementById('game-container');

// --- 설정: 이 부분을 수정하여 룰렛 항목을 변경할 수 있습니다 ---
const options = ["🍎 사과", "🍌 바나나"];
const colors = ["#FF6B6B", "#FAD02E"]; // 빨간색, 노란색
// ----------------------------------------------------

const arcSize = (2 * Math.PI) / options.length; // 각 조각의 크기(각도)
let currentAngle = 0; // 룰렛의 현재 회전 각도를 저장하는 변수

/**
 * 룰렛 판을 그리는 함수.
 * 룰렛의 현재 회전 각도(currentAngle)를 바탕으로 캔버스에 그림을 그립니다.
 */
function drawRoulette() {
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = canvas.width / 2 - 10;

    ctx.clearRect(0, 0, canvas.width, canvas.height); // 캔버스를 깨끗하게 지움
    ctx.save(); // 현재 캔버스 상태(변환, 스타일 등)를 저장

    // 캔버스의 중심을 (0,0)으로 이동시키고, currentAngle만큼 회전시킴
    ctx.translate(centerX, centerY);
    ctx.rotate(currentAngle);
    ctx.translate(-centerX, -centerY);

    // 각 조각(항목)을 순서대로 그림
    for (let i = 0; i < options.length; i++) {
        const startAngle = i * arcSize;
        const endAngle = (i + 1) * arcSize;

        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.arc(centerX, centerY, radius, startAngle, endAngle); // 부채꼴 그리기
        ctx.closePath();

        ctx.fillStyle = colors[i % colors.length]; // 색상 적용
        ctx.fill();

        // 텍스트(아이템 이름) 그리기
        ctx.save();
        ctx.fillStyle = 'black';
        ctx.font = 'bold 20px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        
        // 텍스트가 그려질 각도와 위치 계산
        const textAngle = startAngle + arcSize / 2;
        ctx.translate(centerX + Math.cos(textAngle) * (radius / 1.5), centerY + Math.sin(textAngle) * (radius / 1.5));
        ctx.rotate(textAngle + Math.PI / 2); // 텍스트가 바깥쪽을 향하도록 회전
        ctx.fillText(options[i], 0, 0);
        ctx.restore(); // 텍스트 그리기가 끝난 후 캔버스 상태 복원
    }
    ctx.restore(); // 룰렛 전체 그리기가 끝난 후 캔버스 상태 복원
}

/**
 * '돌리기' 버튼을 눌렀을 때 실행되는 메인 함수
 */
function spinRoulette() {
    if (spinBtn.disabled) return;
    spinBtn.disabled = true;

    // --- 1. 서버에 보낼 옵션 준비 ---
    const params = new URLSearchParams();
    options.forEach(opt => params.append('option', opt));
    const contextPath = gameContainer.dataset.contextPath;

    // --- 2. 서버에 당첨 결과 요청 (fetch API) ---
    fetch(`${contextPath}/roulette?${params.toString()}`)
        .then(response => {
            if (!response.ok) throw new Error('서버와 통신에 실패했습니다.');
            return response.json(); // 응답을 JSON 형태로 파싱
        })
        .then(data => {
            // --- 3. 서버로부터 받은 결과로 애니메이션 실행 ---
            const winner = data.winner;
            const winnerIndex = options.indexOf(winner);

            console.log(`서버 결과: ${winner} (인덱스: ${winnerIndex})`);

            if (winnerIndex === -1) {
                throw new Error('서버로부터 유효하지 않은 결과를 받았습니다.');
            }

            // [목표 각도 계산]
            const pieceCenterAngle = (winnerIndex * arcSize) + (arcSize / 2); // 당첨 조각의 중앙 각도
            const pointerAngle = 1.5 * Math.PI; // 포인터는 270도(윗 방향)에 위치
            
            // 룰렛이 최종적으로 멈춰야 할 각도 = 포인터 위치 - 당첨 조각의 중앙 위치
            const targetRotation = pointerAngle - pieceCenterAngle;
            
            // 자연스러운 회전을 위해 최소 10바퀴 이상 추가 회전
            const totalRotation = (10 * 2 * Math.PI) + targetRotation;

            // [애니메이션 실행]
            let startTimestamp = null;
            const duration = 5000; // 5초 동안 애니메이션 실행

            function animate(timestamp) {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = timestamp - startTimestamp;
                
                // Ease-out 효과: 처음엔 빠르다가 끝에 천천히 멈추는 효과
                const easeOut = 1 - Math.pow(1 - (progress / duration), 4);
                currentAngle = totalRotation * easeOut; // 현재 프레임의 회전 각도 계산

                drawRoulette(); // 계산된 각도로 룰렛을 다시 그림

                if (progress < duration) {
                    requestAnimationFrame(animate); // 다음 프레임 요청
                } else {
                    // --- 4. 애니메이션 종료 후 최종 처리 ---
                    currentAngle = totalRotation; // 오차 보정을 위해 최종 각도로 한번 더 설정
                    drawRoulette();
                    setTimeout(() => {
                        alert(`🎉 결과: ${winner} 🎉`);
                        spinBtn.disabled = false; // 버튼 다시 활성화
                    }, 100);
                }
            }
            requestAnimationFrame(animate); // 애니메이션 시작
        })
        .catch(error => {
            console.error('Error:', error);
            alert(error.message);
            spinBtn.disabled = false; // 에러 발생 시 버튼 다시 활성화
        });
}

// --- 이벤트 리스너 및 초기화 ---
spinBtn.addEventListener('click', spinRoulette);
drawRoulette(); // 페이지 로드 시 초기 룰렛 그리기
