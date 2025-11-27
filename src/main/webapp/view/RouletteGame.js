console.log("RouletteGame.js 로드됨 ✅");

// --- 변수 선언 ---
const canvas = document.getElementById('roulette-canvas');
const ctx = canvas.getContext('2d');
const cashDisplay = document.getElementById("my-cash");
const betInput = document.getElementById("betAmount");
const gameContainer = document.getElementById("game-container");

// JSP에서 동적으로 생성된 options 배열을 사용합니다.
const colors = ["#FF6B6B", "#FAD02E", "#4ECCA3", "#36A2EB", "#FF9F40", "#9966FF", "#FFCD56", "#C9CBCF", "#4BC0C0", "#FF6384"];
const arcSize = (2 * Math.PI) / options.length;
let currentAngle = 0;
let isSpinning = false; 
let selectedSegmentIndex = -1; // 사용자가 선택한 칸의 인덱스

// --- 함수 정의 ---

// 룰렛을 그리는 함수
function drawRoulette() {
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;
    const radius = cx - 10;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(currentAngle);
    ctx.translate(-cx, -cy);
    
    for(let i = 0; i < options.length; i++) {
        const start = i * arcSize;
        const end = (i + 1) * arcSize;
        
        ctx.beginPath();
        ctx.moveTo(cx, cy); 
        ctx.arc(cx, cy, radius, start, end);
        ctx.fillStyle = colors[i % colors.length];
        ctx.fill();
        ctx.stroke();
        
        ctx.save();
        
        // 선택된 칸의 글씨 색 변경
        if (i === selectedSegmentIndex) {
            if (options[i] === "레몬") {
                ctx.fillStyle = "red"; // '레몬'은 노란색 배경이므로 글씨를 빨간색으로
            } else {
                ctx.fillStyle = "#FFD700"; // 다른 과일은 밝은 노란색
            }
        } else {
            ctx.fillStyle = "black";
        }

        ctx.font = "bold 20px Arial";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        const textAngle = start + arcSize / 2;
        const tx = cx + Math.cos(textAngle) * (radius * 0.7);
        const ty = cy + Math.sin(textAngle) * (radius * 0.7);
        ctx.translate(tx, ty);
        ctx.rotate(textAngle + Math.PI / 2);
        ctx.fillText(options[i], 0, 0);
        ctx.restore();
    }
    ctx.restore();
}

// 캔버스 클릭 이벤트를 처리하는 함수
function handleCanvasClick(event) {
    if (isSpinning) {
        alert("룰렛이 돌아가는 중입니다. 잠시만 기다려주세요.");
        return;
    }

    const rect = canvas.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;

    const dist = Math.sqrt(Math.pow(x - cx, 2) + Math.pow(y - cy, 2));
    if (dist > (cx - 10)) { // 룰렛 바깥쪽 클릭은 무시
        return;
    }

    let clickAngle = Math.atan2(y - cy, x - cx) - currentAngle;
    if (clickAngle < 0) clickAngle += 2 * Math.PI;
    clickAngle %= (2 * Math.PI);

    const segmentIndex = Math.floor(clickAngle / arcSize);
    const selectedFruit = options[segmentIndex];
    
    selectedSegmentIndex = segmentIndex;
    drawRoulette(); // 선택한 칸의 글씨색을 변경하여 다시 그림

    const bet = betInput.value;
    if (bet <= 0) {
        alert("베팅 금액을 100원 이상으로 설정해주세요.");
        selectedSegmentIndex = -1; // 선택 취소
        drawRoulette();
        return;
    }

    const confirmation = confirm(`"${selectedFruit}"에 ${bet}원을 배팅하시겠습니까?`);

    if (confirmation) {
        spin(selectedFruit, bet);
    } else {
        selectedSegmentIndex = -1; // 사용자가 '취소'하면 글씨색을 원래대로 되돌림
        drawRoulette();
    }
}

// 룰렛을 돌리고 서버와 통신하는 함수
function spin(pick, bet) {
    isSpinning = true;
    const contextPath = gameContainer.dataset.contextPath;
    
    const params = new URLSearchParams();
    options.forEach(o => params.append("option", o));
    params.append("bet", bet);
    params.append("userPick", pick);
    
    fetch(`${contextPath}/roulette?${params.toString()}`)
        .then(res => res.json())
        .then(data => {
            if (data.error) throw new Error(data.error);
            
            const winnerIdx = options.indexOf(data.winner);
            const winnerCenterAngle = (winnerIdx * arcSize) + (arcSize / 2);
            const targetRotation = (1.5 * Math.PI) - winnerCenterAngle;
            const totalRotation = targetRotation + (10 * 2 * Math.PI);
            
            let startTimestamp = null;
            const duration = 4000;

            function animate(timestamp) {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = timestamp - startTimestamp;
                
                if (progress < duration) {
                    const easeOutRate = 1 - Math.pow(1 - (progress / duration), 3);
                    currentAngle = totalRotation * easeOutRate;
                    drawRoulette();
                    requestAnimationFrame(animate);
                } else {
                    currentAngle = totalRotation % (2 * Math.PI);
                    drawRoulette();
                    setTimeout(() => {
                        alert(data.message);
                        if(cashDisplay) {
                            cashDisplay.innerText = data.currentCash.toLocaleString('en-US');
                        }
                        
                        // 게임 종료 후 상태 초기화
                        selectedSegmentIndex = -1;
                        isSpinning = false;
                        drawRoulette(); // 글씨 색을 원래대로 되돌리기 위해 다시 그림
                    }, 100);
                }
            }
            requestAnimationFrame(animate);
        })
        .catch(err => {
            alert(err.message || "오류가 발생했습니다. 다시 시도해주세요.");
            isSpinning = false;
            selectedSegmentIndex = -1;
            drawRoulette();
        });
}

function handleRegenerate() {
    const newCountInput = document.getElementById("fruitCountInput");
    const newCount = parseInt(newCountInput.value, 10);
    if (isNaN(newCount) || newCount < 2 || newCount > 10) {
        alert("2에서 10 사이의 올바른 과일 개수를 입력하세요.");
        return;
    }
    const contextPath = gameContainer.dataset.contextPath;
    // Reload the page with the new fruit count
    window.location.href = `${contextPath}/roulette?fruitCount=${newCount}`;
}

// --- 초기화 ---
canvas.addEventListener('click', handleCanvasClick);
document.getElementById("regenerate-form").onsubmit = function(e) {
    e.preventDefault();
    handleRegenerate();
};
drawRoulette();