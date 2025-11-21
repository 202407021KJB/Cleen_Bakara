console.log("LadderGame.js 로드됨 ✅");

const canvas = document.getElementById("ladderCanvas");
const ctx = canvas.getContext("2d");
const playerInputsContainer = document.getElementById("player-inputs");
const resultOutputsContainer = document.getElementById("result-outputs");
const betInput = document.getElementById("betAmount");
const cashDisplay = document.getElementById("my-cash");

const LADDER_TOP = 50;
const LADDER_BOTTOM = canvas.height - 50;

let ladderData = null;
let isAnimating = false;
const numPlayers = 2;

function initializeGame() {
    // 참가자 버튼 생성
    playerInputsContainer.innerHTML = '';
    const labels = ['좌', '우'];
    for (let i = 0; i < numPlayers; i++) {
        const btn = document.createElement('button');
        btn.className = 'player-box';
        btn.innerText = labels[i];
        btn.onclick = () => startGame(i); // 클릭 시 게임 시작
        playerInputsContainer.appendChild(btn);
    }

    // 결과 박스 생성
    resultOutputsContainer.innerHTML = '';
    const results = ["당첨", "꽝"];
    for (let i = 0; i < numPlayers; i++) {
        const div = document.createElement('div');
        div.className = 'result-box';
        div.innerText = results[i];
        resultOutputsContainer.appendChild(div);
    }
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

function startGame(pickIndex) {
    if (isAnimating) return;
    
    const bet = betInput.value;
    if (bet <= 0) {
        alert("올바른 베팅 금액을 입력하세요.");
        return;
    }
    
    const label = pickIndex === 0 ? '좌' : '우';
    if (!confirm(`${bet}원을 걸고 '${label}'를 선택하시겠습니까?`)) return;

    isAnimating = true;
    const contextPath = document.getElementById('game-container').dataset.contextPath;

    // 서버 요청
    fetch(`${contextPath}/ladder?players=${numPlayers}&pick=${pickIndex}&bet=${bet}`)
        .then(res => res.json())
        .then(data => {
            if (data.error) throw new Error(data.error);
            
            ladderData = data.ladderData;
            drawLadder(ladderData);
            
            // 시각적 경로 계산 및 애니메이션
            const pathResult = findPath(pickIndex, ladderData); 
            animatePath(pathResult, () => {
                alert(data.message);
                if(cashDisplay) cashDisplay.innerText = data.currentCash;
                isAnimating = false;
            });
        })
        .catch(err => {
            alert(err.message || "오류 발생");
            isAnimating = false;
        });
}

function drawLadder(data) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.lineWidth = 2; ctx.strokeStyle = "#000";
    data.xPositions.forEach(x => { 
        ctx.beginPath(); ctx.moveTo(x, LADDER_TOP); ctx.lineTo(x, LADDER_BOTTOM); ctx.stroke(); 
    });
    data.rungs.forEach(r => {
        const x1 = data.xPositions[r.col];
        const x2 = data.xPositions[r.col + 1];
        ctx.beginPath(); ctx.moveTo(x1, r.y); ctx.lineTo(x2, r.y); ctx.stroke();
    });
}

function findPath(startCol, data) {
    const { xPositions, rungs } = data;
    const path = [[xPositions[startCol], LADDER_TOP]];
    let col = startCol;
    const sortedRungs = [...rungs].sort((a, b) => a.y - b.y);
    
    sortedRungs.forEach(r => {
        if (r.col === col || r.col === col - 1) {
            path.push([xPositions[col], r.y]);
            col = (r.col === col) ? col + 1 : col - 1;
            path.push([xPositions[col], r.y]);
        }
    });
    path.push([xPositions[col], LADDER_BOTTOM]);
    return { path, endCol: col };
}

function animatePath(result, callback) {
    const { path, endCol } = result;
    let idx = 0;
    let currX = path[0][0], currY = path[0][1];
    
    const resultBoxes = document.querySelectorAll('.result-box');
    resultBoxes.forEach(b => { b.style.backgroundColor = ''; b.style.border = '2px solid #e0e0e0'; });

    function step() {
        if (idx >= path.length - 1) {
            resultBoxes[endCol].style.backgroundColor = 'gold';
            resultBoxes[endCol].style.border = '2px solid #ffd700';
            if (callback) callback();
            return;
        }
        const [nextX, nextY] = path[idx + 1];
        ctx.beginPath(); ctx.lineWidth = 3; ctx.strokeStyle = 'red';
        ctx.moveTo(currX, currY); ctx.lineTo(nextX, nextY); ctx.stroke();
        
        currX = nextX; currY = nextY;
        idx++;
        setTimeout(() => requestAnimationFrame(step), 50);
    }
    step();
}

initializeGame();