console.log("RouletteGame.js 로드됨 ✅");

const spinBtn = document.getElementById('spin-btn');
const canvas = document.getElementById('roulette-canvas');
const ctx = canvas.getContext('2d');
const cashDisplay = document.getElementById("my-cash");
const betInput = document.getElementById("betAmount");
const pickInput = document.getElementById("userPick");
const gameContainer = document.getElementById("game-container");

const options = ["사과", "바나나"];
const colors = ["#FF6B6B", "#FAD02E"];
const arcSize = (2 * Math.PI) / options.length;
let currentAngle = 0;

function drawRoulette() {
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;
    const radius = cx - 10;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.save(); ctx.translate(cx, cy); ctx.rotate(currentAngle); ctx.translate(-cx, -cy);
    
    for(let i = 0; i < options.length; i++) {
        const start = i * arcSize;
        const end = (i + 1) * arcSize;
        
        ctx.beginPath(); ctx.moveTo(cx, cy); 
        ctx.arc(cx, cy, radius, start, end);
        ctx.fillStyle = colors[i % colors.length]; ctx.fill(); ctx.stroke();
        
        ctx.save(); 
        ctx.fillStyle = "black"; ctx.font = "bold 20px Arial";
        ctx.textAlign = "center"; ctx.textBaseline = "middle";
        const textAngle = start + arcSize / 2;
        const tx = cx + Math.cos(textAngle) * (radius * 0.7);
        const ty = cy + Math.sin(textAngle) * (radius * 0.7);
        ctx.translate(tx, ty); ctx.rotate(textAngle + Math.PI / 2);
        ctx.fillText(options[i], 0, 0);
        ctx.restore();
    }
    ctx.restore();
}

function spin() {
    const bet = betInput.value;
    const pick = pickInput.value;
    
    if (bet <= 0) {
        alert("베팅 금액을 확인하세요.");
        return;
    }
    
    spinBtn.disabled = true;
    const contextPath = gameContainer.dataset.contextPath;
    
    const params = new URLSearchParams();
    options.forEach(o => params.append("option", o));
    params.append("bet", bet);
    params.append("userPick", pick);
    
    fetch(`${contextPath}/roulette?${params.toString()}`)
        .then(res => res.json())
        .then(data => {
            if (data.error) throw new Error(data.error);
            
            // 당첨 위치 계산 (12시 방향이 270도)
            const winnerIdx = options.indexOf(data.winner);
            const winnerCenterAngle = (winnerIdx * arcSize) + (arcSize / 2);
            const targetRotation = (1.5 * Math.PI) - winnerCenterAngle;
            const totalRotation = targetRotation + (10 * 2 * Math.PI);
            
            let startTimestamp = null;
            const duration = 4000;

            function animate(timestamp) {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = (timestamp - startTimestamp);
                
                if (progress < duration) {
                    const rate = 1 - Math.pow(1 - (progress / duration), 3);
                    currentAngle = totalRotation * rate;
                    drawRoulette();
                    requestAnimationFrame(animate);
                } else {
                    currentAngle = totalRotation % (2 * Math.PI);
                    drawRoulette();
                    setTimeout(() => {
                        alert(data.message);
                        if(cashDisplay) cashDisplay.innerText = data.currentCash;
                        spinBtn.disabled = false;
                    }, 100);
                }
            }
            requestAnimationFrame(animate);
        })
        .catch(err => {
            alert(err.message || "오류 발생");
            spinBtn.disabled = false;
        });
}

spinBtn.addEventListener('click', spin);
drawRoulette();