console.log("LadderGame.js 로드됨 ✅ (v3.0)");

const gameContainer = document.getElementById("game-container");
const ladderContainer = document.getElementById("ladder-container");
const canvas = document.getElementById("ladderCanvas");
const ctx = canvas.getContext("2d");
const betInput = document.getElementById("betAmount");
const cashDisplay = document.getElementById("my-cash");
const replayBtn = document.getElementById("replay-btn");

// --- Constants and State ---
const LADDER_TOP_MARGIN = 30; // Top space for animal names
const LADDER_BOTTOM_MARGIN = 50; // Bottom space for results (40px box + 20px margin)
const LADDER_VERTICAL_TOP = LADDER_TOP_MARGIN;
const LADDER_VERTICAL_BOTTOM = canvas.height - LADDER_BOTTOM_MARGIN;
const LADDER_WIDTH = canvas.width;
const ANIMATION_DURATION = 1500;

const ANIMAL_COUNT = parseInt(gameContainer.dataset.animalCount, 10);
const ALL_ANIMALS = ["돼지", "코끼리", "원숭이", "사자", "호랑이", "기린", "하마", "악어", "펭귄", "판다"];
const GAME_ANIMALS = ALL_ANIMALS.slice(0, ANIMAL_COUNT);

let ladderData = null;
let isAnimating = false;
let xPositions = [];

// --- Core Functions ---

function calculateXPositions() {
    const positions = [];
    const stepX = LADDER_WIDTH / (ANIMAL_COUNT + 1);
    for (let i = 0; i < ANIMAL_COUNT; i++) {
        positions.push(stepX * (i + 1));
    }
    return positions;
}

function resetGame() {
    isAnimating = false;
    betInput.disabled = false;
    replayBtn.style.display = 'none';

    // Clear previous elements
    const elementsToRemove = ladderContainer.querySelectorAll('.player-box, .result-box');
    elementsToRemove.forEach(el => el.remove());

    xPositions = calculateXPositions();

    for (let i = 0; i < ANIMAL_COUNT; i++) {
        const x = xPositions[i];

        // Create and position player button
        const btn = document.createElement('button');
        btn.className = 'player-box';
        btn.innerText = GAME_ANIMALS[i];
        btn.style.position = 'absolute';
        btn.style.top = '0px';
        btn.style.left = `${x - 40}px`; // 80px width / 2
        btn.onclick = () => startGame(i);
        ladderContainer.appendChild(btn);

        // Create and position result box
        const div = document.createElement('div');
        div.className = 'result-box';
        div.innerText = '?';
        div.style.position = 'absolute';
        div.style.bottom = '0px';
        div.style.left = `${x - 40}px`; // 80px width / 2
        ladderContainer.appendChild(div);
    }
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}


function startGame(pickIndex) {
    if (isAnimating) return;

    const betValue = parseInt(betInput.value, 10);
    const currentCash = parseInt(cashDisplay.innerText.replace(/,/g, ''), 10);

    if (isNaN(betValue) || betValue <= 0) {
        alert("베팅 금액을 올바르게 입력하세요.");
        return;
    }
    if (betValue > currentCash) {
        alert("보유 캐시보다 많이 베팅할 수 없습니다.");
        return;
    }
    if (!confirm(`'${GAME_ANIMALS[pickIndex]}'에 ${betValue.toLocaleString()}원을 베팅하시겠습니까?`)) {
        return;
    }

    isAnimating = true;
    document.querySelectorAll('.player-box').forEach(b => b.disabled = true);
    betInput.disabled = true;

    const contextPath = gameContainer.dataset.contextPath;

    fetch(`${contextPath}/ladder?players=${ANIMAL_COUNT}&pick=${pickIndex}&bet=${betValue}`)
        .then(res => {
            if (!res.ok) throw new Error(`Server responded with status: ${res.status}`);
            return res.json();
        })
        .then(data => {
            if (data.error) throw new Error(data.error);

            ladderData = data.ladderData;
            const results = data.results;

            const resultBoxes = document.querySelectorAll('.result-box');
            resultBoxes.forEach((box, i) => {
                box.innerText = results[i];
            });
            
            drawLadder(ladderData);
            
            const pathResult = findPath(pickIndex, ladderData);
            
            animatePath(pathResult, () => {
                const resultBoxes = document.querySelectorAll('.result-box');
                const finalResult = data.results[pathResult.endCol];

                // 1. Change color of the winning box ONLY
                if (finalResult === '당첨') {
                    resultBoxes[pathResult.endCol].style.backgroundColor = '#2ecc71';
                }
                resultBoxes[pathResult.endCol].style.transform = 'scale(1.1)';
                resultBoxes[pathResult.endCol].style.zIndex = '10';

                // 2. Update cash and show popup after a short delay
                setTimeout(() => {
                    // Clean the message from potential proxy injections
                    const cleanMessage = data.message.replace("localhost8080 내용:", "").trim();
                    alert(cleanMessage);
                    
                    cashDisplay.innerText = data.currentCash.toLocaleString();
                    replayBtn.style.display = 'inline-block';
                }, 100);
            });
        })
        .catch(err => {
            console.error("Fetch Error:", err);
            alert("서버와 통신 중 오류가 발생했습니다. 콘솔을 확인해주세요.");
            resetGame();
        });
}

function drawLadder(data) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.lineWidth = 2;
    ctx.strokeStyle = "#333";
    
    xPositions.forEach(x => {
        ctx.beginPath();
        ctx.moveTo(x, LADDER_VERTICAL_TOP);
        ctx.lineTo(x, LADDER_VERTICAL_BOTTOM);
        ctx.stroke();
    });

    data.rungs.forEach(r => {
        const x1 = xPositions[r.col];
        const x2 = xPositions[r.col + 1];
        ctx.beginPath();
        ctx.moveTo(x1, r.y);
        ctx.lineTo(x2, r.y);
        ctx.stroke();
    });
}

function findPath(startCol, data) {
    const path = [[xPositions[startCol], LADDER_VERTICAL_TOP]];
    let col = startCol;
    const sortedRungs = data.rungs;

    sortedRungs.forEach(r => {
        if (r.col === col || r.col === col - 1) {
            path.push([xPositions[col], r.y]);
            col = (r.col === col) ? col + 1 : col - 1;
            path.push([xPositions[col], r.y]);
        }
    });
    path.push([xPositions[col], LADDER_VERTICAL_BOTTOM]);
    return { path, endCol: col };
}

function animatePath(result, callback) {
    const { path } = result;
    let totalLength = 0;
    for (let i = 0; i < path.length - 1; i++) {
        const [x1, y1] = path[i], [x2, y2] = path[i + 1];
        totalLength += Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    }

    let startTime = null;

    function step(timestamp) {
        if (!startTime) startTime = timestamp;
        const progress = (timestamp - startTime) / ANIMATION_DURATION;
        const distanceToDraw = progress * totalLength;

        drawLadder(ladderData);

        ctx.beginPath();
        ctx.lineWidth = 4;
        ctx.strokeStyle = 'red';

        let distanceTraveled = 0;
        for (let i = 0; i < path.length - 1; i++) {
            const [x1, y1] = path[i], [x2, y2] = path[i + 1];
            const segmentLength = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));

            ctx.moveTo(x1, y1);
            if (distanceTraveled + segmentLength > distanceToDraw) {
                const fraction = (distanceToDraw - distanceTraveled) / segmentLength;
                const stopX = x1 + (x2 - x1) * fraction;
                const stopY = y1 + (y2 - y1) * fraction;
                ctx.lineTo(stopX, stopY);
                break;
            } else {
                ctx.lineTo(x2, y2);
                distanceTraveled += segmentLength;
            }
        }
        ctx.stroke();

        if (progress < 1) {
            requestAnimationFrame(step);
        } else {
            if (callback) callback();
        }
    }
    requestAnimationFrame(step);
}

function handleRegenerate() {
    const newCountInput = document.getElementById("animalCountInput");
    const newCount = parseInt(newCountInput.value, 10);
    if (isNaN(newCount) || newCount < 2 || newCount > 10) {
        alert("2에서 10 사이의 올바른 동물 수를 입력하세요.");
        return;
    }
    const contextPath = gameContainer.dataset.contextPath;
    // Reload the page with the new animal count
    window.location.href = `${contextPath}/view/LadderPage.jsp?animalCount=${newCount}`;
}

// --- Initialization ---
replayBtn.onclick = resetGame;
resetGame();
