console.log("RouletteGame.js 로드됨 ✅ (v1.1 - Click Fix)");

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
let selectedSegmentIndex = -1;

// --- 함수 정의 ---

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
        
        if (i === selectedSegmentIndex) {
            ctx.fillStyle = (options[i] === "레몬") ? "red" : "#FFD700";
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

function handleCanvasClick(event) {
    if (isSpinning) return;

    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    const x = (event.clientX - rect.left) * scaleX;
    const y = (event.clientY - rect.top) * scaleY;
    
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;

    const dist = Math.sqrt(Math.pow(x - cx, 2) + Math.pow(y - cy, 2));
    if (dist > (cx - 10)) return;

    let clickAngle = Math.atan2(y - cy, x - cx) - currentAngle;
    while (clickAngle < 0) { clickAngle += 2 * Math.PI; }
    clickAngle %= (2 * Math.PI);

    const segmentIndex = Math.floor(clickAngle / arcSize);
    const selectedFruit = options[segmentIndex];
    
    selectedSegmentIndex = segmentIndex;
    drawRoulette();

    const bet = betInput.value;
    if (bet <= 0) {
        alert("베팅 금액을 100원 이상으로 설정해주세요.");
        selectedSegmentIndex = -1;
        drawRoulette();
        return;
    }

    const confirmation = confirm(`"${selectedFruit}"에 ${bet}원을 배팅하시겠습니까?`);
    if (confirmation) {
        spin(selectedFruit, bet);
    } else {
        selectedSegmentIndex = -1;
        drawRoulette();
    }
}

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
                        selectedSegmentIndex = -1;
                        isSpinning = false;
                        drawRoulette();
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
    window.location.href = `${contextPath}/roulette?fruitCount=${newCount}`;
}

// --- 초기화 ---
canvas.addEventListener('click', handleCanvasClick);
document.getElementById("regenerate-form").onsubmit = function(e) {
    e.preventDefault();
    handleRegenerate();
};
drawRoulette();