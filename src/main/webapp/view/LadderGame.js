console.log("LadderGame.js 로드됨 ✅ (v9.0 - Final Polish)");

// =================================================================================
// 1. CONFIG & DOM ELEMENTS
// =================================================================================

const BASE_CANVAS_WIDTH = 800;
const BASE_CANVAS_HEIGHT = 400;
const BASE_BOX_SIZE = 80; // Base size for PC
const BASE_FONT_SIZE = 16;
const BASE_MARGIN_TOP = 100; // Margin is now based on the fixed box size
const BASE_MARGIN_BOTTOM = 100;

const gameContainer = document.getElementById("game-container");
const ladderContainer = document.getElementById("ladder-container");
const canvas = document.getElementById("ladderCanvas");
const ctx = canvas.getContext("2d");
const betInput = document.getElementById("betAmount");
const cashDisplay = document.getElementById("my-cash");
const replayBtn = document.getElementById("replay-btn");

const ANIMAL_COUNT = parseInt(gameContainer.dataset.animalCount, 10);
const ALL_ANIMALS = ["돼지", "코끼리", "원숭이", "사자", "호랑이", "기린", "하마", "악어", "펭귄", "판다"];
const GAME_ANIMALS = ALL_ANIMALS.slice(0, ANIMAL_COUNT);
let ladderData = null;
let isAnimating = false;

// =================================================================================
// 2. LAYOUT ENGINE
// =================================================================================

function layoutEngine() {
    const containerWidth = gameContainer.offsetWidth;
    const scale = Math.min(1, containerWidth / BASE_CANVAS_WIDTH);

    const scaledCanvasWidth = BASE_CANVAS_WIDTH * scale;
    const scaledCanvasHeight = BASE_CANVAS_HEIGHT * scale;
    
    // [FIX] Box size is now constant, not scaled.
    const boxSize = BASE_BOX_SIZE; 
    const scaledFontSize = Math.max(10, BASE_FONT_SIZE * scale);

    // Margins are scaled to keep spacing proportional
    const scaledMarginTop = boxSize * 1.2;
    const scaledMarginBottom = boxSize * 1.2;

    ladderContainer.style.position = 'relative';
    ladderContainer.style.width = `${scaledCanvasWidth}px`;
    ladderContainer.style.height = `${scaledCanvasHeight}px`;
    ladderContainer.style.marginTop = `${scaledMarginTop}px`;
    ladderContainer.style.marginBottom = `${scaledMarginBottom}px`;
    ladderContainer.style.marginLeft = 'auto';
    ladderContainer.style.marginRight = 'auto';

    canvas.style.width = '100%';
    canvas.style.height = '100%';

    const xPositions = [];
    const stepX = scaledCanvasWidth / (ANIMAL_COUNT + 1);
    for (let i = 0; i < ANIMAL_COUNT; i++) {
        xPositions.push(stepX * (i + 1));
    }

    const playerBoxes = ladderContainer.querySelectorAll('.player-box');
    const resultBoxes = ladderContainer.querySelectorAll('.result-box');

    playerBoxes.forEach((box, i) => {
        box.style.position = 'absolute';
        box.style.width = `${boxSize}px`;
        box.style.height = `${boxSize}px`;
        box.style.fontSize = `${scaledFontSize}px`;
        box.style.left = `${xPositions[i] - (boxSize / 2)}px`;
        box.style.top = `-${scaledMarginTop / 2}px`;
        box.style.transform = 'translateY(-50%)';
    });

    resultBoxes.forEach((box, i) => {
        box.style.position = 'absolute';
        box.style.width = `${boxSize}px`;
        box.style.height = `${boxSize}px`;
        box.style.fontSize = `${scaledFontSize}px`;
        box.style.left = `${xPositions[i] - (boxSize / 2)}px`;
        box.style.bottom = `-${scaledMarginBottom / 2}px`;
        box.style.transform = 'translateY(50%)';
    });
}


// =================================================================================
// 3. GAME LOGIC
// =================================================================================

function resetGame() {
    // Removed console.log
    isAnimating = false;
    betInput.disabled = false;
    replayBtn.style.display = 'none';

    ladderContainer.innerHTML = ''; 
    ladderContainer.appendChild(canvas);

    for (let i = 0; i < ANIMAL_COUNT; i++) {
        const btn = document.createElement('button');
        btn.className = 'player-box';
        btn.innerText = GAME_ANIMALS[i];
        btn.onclick = () => startGame(i);
        ladderContainer.appendChild(btn);

        const div = document.createElement('div');
        div.className = 'result-box';
        div.innerText = '?';
        ladderContainer.appendChild(div);
    }
    
    layoutEngine(); 
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

function startGame(pickIndex) {
    if (isAnimating) return;
    const betValue = parseInt(betInput.value, 10);
    const currentCash = parseInt(cashDisplay.innerText.replace(/,/g, ''), 10);
    if (isNaN(betValue) || betValue <= 0) { alert("베팅 금액을 올바르게 입력하세요."); return; }
    if (betValue > currentCash) { alert("보유 캐시보다 많이 베팅할 수 없습니다."); return; }
    if (!confirm(`'${GAME_ANIMALS[pickIndex]}'에 ${betValue.toLocaleString()}원을 베팅하시겠습니까?`)) { return; }
    isAnimating = true;
    document.querySelectorAll('.player-box').forEach(b => b.disabled = true);
    betInput.disabled = true;
    const contextPath = gameContainer.dataset.contextPath;
    fetch(`${contextPath}/ladder?players=${ANIMAL_COUNT}&pick=${pickIndex}&bet=${betValue}`)
        .then(res => res.json())
        .then(data => {
            if (data.error) throw new Error(data.error);
            ladderData = data.ladderData;
            const results = data.results;
            const resultBoxes = ladderContainer.querySelectorAll('.result-box');
            resultBoxes.forEach((box, i) => { box.innerText = results[i]; });
            drawLadder(ladderData);
            const pathResult = findPath(pickIndex, ladderData);
            animatePath(pathResult, () => {
                const resultBoxes = ladderContainer.querySelectorAll('.result-box');
                const finalResult = data.results[pathResult.endCol];
                if (finalResult === '당첨') {
                    resultBoxes[pathResult.endCol].style.backgroundColor = '#2ecc71';
                }
                resultBoxes[pathResult.endCol].style.transform += ' scale(1.1)';
                setTimeout(() => {
                    alert(data.message.replace("localhost8080 내용:", "").trim());
                    cashDisplay.innerText = data.currentCash.toLocaleString();
                    replayBtn.style.display = 'inline-block';
                }, 100);
            });
        })
        .catch(err => {
            console.error("Fetch Error:", err);
            alert("서버와 통신 중 오류가 발생했습니다.");
            isAnimating = false;
            document.querySelectorAll('.player-box').forEach(b => b.disabled = false);
            betInput.disabled = false;
        });
}

function drawLadder(data) {
    const xPositions = [];
    const stepX = BASE_CANVAS_WIDTH / (ANIMAL_COUNT + 1);
    for (let i = 0; i < ANIMAL_COUNT; i++) { xPositions.push(stepX * (i + 1)); }

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.lineWidth = 2;
    ctx.strokeStyle = "#333";
    xPositions.forEach(x => {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, BASE_CANVAS_HEIGHT);
        ctx.stroke();
    });
    if (data && data.rungs) {
        data.rungs.forEach(r => {
            const x1 = xPositions[r.col];
            const x2 = xPositions[r.col + 1];
            ctx.beginPath();
            ctx.moveTo(x1, r.y);
            ctx.lineTo(x2, r.y);
            ctx.stroke();
        });
    }
}

function findPath(startCol, data) {
    const xPositions = [];
    const stepX = BASE_CANVAS_WIDTH / (ANIMAL_COUNT + 1);
    for (let i = 0; i < ANIMAL_COUNT; i++) { xPositions.push(stepX * (i + 1)); }

    const path = [[xPositions[startCol], 0]];
    let col = startCol;
    if (data && data.rungs) {
        const sortedRungs = data.rungs.sort((a, b) => a.y - b.y);
        sortedRungs.forEach(r => {
            if (r.col === col) {
                path.push([xPositions[col], r.y]);
                col = col + 1;
                path.push([xPositions[col], r.y]);
            } else if (r.col === col - 1) {
                path.push([xPositions[col], r.y]);
                col = col - 1;
                path.push([xPositions[col], r.y]);
            }
        });
    }
    path.push([xPositions[col], BASE_CANVAS_HEIGHT]);
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
        const progress = (timestamp - startTime) / 1500;
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
    let newCount = parseInt(newCountInput.value, 10);
    const isMobile = window.innerWidth <= 768;
    const maxAnimals = isMobile ? 3 : 10;
    if (isNaN(newCount) || newCount < 2 || newCount > maxAnimals) {
        alert(`2에서 ${maxAnimals} 사이의 올바른 동물 수를 입력하세요.`);
        newCountInput.value = Math.max(2, Math.min(newCount, maxAnimals));
        return;
    }
    const contextPath = gameContainer.dataset.contextPath;
    window.location.href = `${contextPath}/view/LadderPage.jsp?animalCount=${newCount}&ver=${Date.now()}`;
}

function applyMobileLimitations() {
    const isMobile = window.innerWidth <= 768;
    if (isMobile) {
        const animalCountInput = document.getElementById("animalCountInput");
        const maxAnimals = 3;
        if (animalCountInput) {
            animalCountInput.max = maxAnimals;
            if (parseInt(animalCountInput.value, 10) > maxAnimals) {
                animalCountInput.value = maxAnimals;
                handleRegenerate(); 
            }
        }
    }
}

// =================================================================================
// 4. INITIALIZATION & EVENT LISTENERS
// =================================================================================

// --- Run on Load
applyMobileLimitations();
resetGame();

// --- Attach Event Listeners
replayBtn.onclick = resetGame;
window.addEventListener('resize', layoutEngine);
