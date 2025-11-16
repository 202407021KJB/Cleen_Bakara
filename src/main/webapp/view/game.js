/**
 * @file game.js
 * 사다리 게임의 클라이언트 사이드 로직을 담당합니다.
 * '사다리 생성' 버튼 클릭 시 서버에 데이터를 요청하고,
 * '좌', '우' 박스 클릭 시 해당 경로를 애니메이션으로 보여줍니다.
 */

console.log("game.js 로드됨 ✅ (v2.2 주석 추가)");

// --- 1. 전역 변수 및 DOM 요소 초기화 ---

// HTML 문서에서 필요한 요소들을 가져와 변수에 저장합니다.
const startBtn = document.getElementById("startBtn");
const canvas = document.getElementById("ladderCanvas");
const ctx = canvas.getContext("2d");
const playerInputsContainer = document.getElementById("player-inputs");
const resultOutputsContainer = document.getElementById("result-outputs");

// 사다리 그림을 그릴 때 사용할 고정된 좌표 값들입니다.
const LADDER_TOP = 50;
const LADDER_BOTTOM = canvas.height - 50;
const LADDER_LEFT = 50;
const LADDER_RIGHT = canvas.width - 50;

let ladderData = null; // 서버로부터 받은 사다리 데이터를 저장할 변수
let isAnimating = false; // 현재 애니메이션이 실행 중인지 여부를 저장하는 변수
let numPlayers = 2; // 참가자 수를 2명으로 고정

/**
 * 게임 전체를 초기화하는 함수.
 * 페이지가 처음 로드될 때 한 번 호출됩니다.
 */
function initializeGame() {
    createInputBoxes(numPlayers); // 시작점, 결과 UI 생성
    clearCanvas(); // 캔버스를 깨끗하게 지움
}

/**
 * 참가자 수에 맞게 시작점('좌', '우')과 결과('당첨', '꽝') UI를 생성합니다.
 * @param {number} count - 참가자 수
 */
function createInputBoxes(count) {
    playerInputsContainer.innerHTML = '';
    resultOutputsContainer.innerHTML = '';

    // 참가자 입력 박스('좌', '우') 생성
    for (let i = 0; i < count; i++) {
        const playerDiv = document.createElement('div');
        playerDiv.className = 'player-box';
        playerDiv.innerHTML = `<input type="text" value="${i === 0 ? '좌' : '우'}" readonly>`;
        
        // ★ 핵심 기능: '좌', '우' 원형 박스에 클릭 이벤트를 직접 부여합니다.
        playerDiv.addEventListener('click', () => {
            // 사다리 데이터가 없거나, 다른 애니메이션이 실행 중이면 아무것도 하지 않음
            if (!ladderData || isAnimating) return;
            
            // 클릭한 시작점(i)으로부터 최종 도착점(endCol)을 계산
            const result = findPath(i);
            
            // 계산된 경로를 바탕으로 애니메이션 시작
            animatePath(result);
        });

        playerInputsContainer.appendChild(playerDiv);
    }

    // 결과 출력 박스('당첨', '꽝') 생성
    const results = ["당첨", "꽝"];
    for (let i = 0; i < count; i++) {
        const resultDiv = document.createElement('div');
        resultDiv.className = 'result-box';
        resultDiv.innerHTML = `<input type="text" value="${results[i]}" readonly>`;
        resultOutputsContainer.appendChild(resultDiv);
    }
}

/**
 * 캔버스의 모든 내용을 지우는 함수
 */
function clearCanvas() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

/**
 * 서버로부터 받은 데이터를 기반으로 캔버스에 사다리를 그립니다.
 * @param {object} data - 서버에서 받은 사다리 데이터 (xPositions, rungs)
 */
function drawLadder(data) {
    clearCanvas();
    if (!data) return;
    
    ctx.lineWidth = 2;
    ctx.strokeStyle = "#000";

    // 세로줄 그리기
    data.xPositions.forEach((x) => {
        ctx.beginPath();
        ctx.moveTo(x, LADDER_TOP);
        ctx.lineTo(x, LADDER_BOTTOM);
        ctx.stroke();
    });

    // 가로줄(가로대) 그리기
    data.rungs.forEach(({ y, col }) => {
        const x1 = data.xPositions[col];
        const x2 = data.xPositions[col + 1];
        ctx.beginPath();
        ctx.moveTo(x1, y);
        ctx.lineTo(x2, y);
        ctx.stroke();
    });
}

/**
 * 시작 지점부터 사다리 규칙에 따라 경로를 계산하여 반환하는 함수
 * @param {number} startCol - 시작하는 세로줄의 인덱스 (0 또는 1)
 * @returns {{path: Array<[number, number]>, endCol: number}} - 경로 좌표 배열과 최종 도착 인덱스
 */
function findPath(startCol) {
    const { xPositions, rungs } = ladderData;
    const path = []; // 이동 경로를 저장할 배열
    let currentCol = startCol;
    let currentY = LADDER_TOP;

    path.push([xPositions[currentCol], currentY]); // 시작점 추가

    // 모든 가로줄을 y좌표 기준으로 정렬
    const yLevels = [...new Set(rungs.map(r => r.y))].sort((a, b) => a - b);

    // 각 가로줄 레벨을 순회하며 경로 탐색
    for (const levelY of yLevels) {
        path.push([xPositions[currentCol], levelY]); // 현재 레벨까지 직선으로 내려온 경로 추가
        
        // 현재 레벨에서 내가 건너야 할 가로줄이 있는지 확인
        const rungToCross = rungs.find(r => r.y === levelY && (r.col === currentCol || r.col === currentCol - 1));
        
        if (rungToCross) { // 건너야 할 가로줄이 있다면
            if (rungToCross.col === currentCol) { // 오른쪽으로 이동
                currentCol++;
            } else { // 왼쪽으로 이동
                currentCol--;
            }
            path.push([xPositions[currentCol], levelY]); // 가로줄을 건넌 후의 위치 추가
        }
    }

    path.push([xPositions[currentCol], LADDER_BOTTOM]); // 최종 도착점까지의 경로 추가
    return { path, endCol: currentCol }; // 계산된 전체 경로와 최종 도착 인덱스 반환
}

/**
 * findPath에서 계산된 경로를 따라 선을 그리며 애니메이션을 보여주는 함수
 * @param {object} result - findPath 함수가 반환한 결과 객체
 */
function animatePath(result) {
    isAnimating = true; // 애니메이션 시작 플래그
    startBtn.disabled = true; // 애니메이션 중에는 '사다리 생성' 버튼 비활성화
    const { path, endCol } = result;
    let currentPoint = 0;
    let currentX = path[0][0];
    let currentY = path[0][1];
    const speed = 15;

    // 결과 박스 스타일 초기화
    const resultBoxes = resultOutputsContainer.querySelectorAll('.result-box');
    resultBoxes.forEach(box => {
        box.style.backgroundColor = '';
        box.style.border = '2px solid #e0e0e0';
    });

    // 애니메이션 프레임마다 실행될 함수
    function animate() {
        // 애니메이션 종료 조건: 마지막 지점에 도달했을 때
        if (currentPoint >= path.length - 1) {
            isAnimating = false;
            startBtn.disabled = false;
            
            // ★ 핵심 기능: 최종 도착점의 원 전체를 노란색으로 강조
            resultBoxes[endCol].style.backgroundColor = 'gold';
            resultBoxes[endCol].style.border = '2px solid #ffd700';

            // 최종 경로를 파란색으로 캔버스에 다시 한번 그려줌
            drawLadder(ladderData);
            ctx.beginPath();
            ctx.strokeStyle = 'blue';
            ctx.lineWidth = 3;
            for (let i = 0; i < path.length; i++) {
                ctx.lineTo(path[i][0], path[i][1]);
            }
            ctx.stroke();
            return; // 애니메이션 종료
        }

        drawLadder(ladderData); // 매 프레임마다 사다리를 다시 그려서 이전 경로를 지움

        const targetX = path[currentPoint + 1][0];
        const targetY = path[currentPoint + 1][1];

        // 실시간으로 이동 경로를 빨간색으로 그림
        ctx.beginPath();
        ctx.strokeStyle = 'red';
        ctx.lineWidth = 3;
        for (let i = 0; i <= currentPoint; i++) {
            ctx.lineTo(path[i][0], path[i][1]);
        }
        ctx.lineTo(currentX, currentY);
        ctx.stroke();

        // 현재 위치(currentX, currentY)를 목표 지점(targetX, targetY)으로 이동
        if (currentY < targetY) currentY = Math.min(currentY + speed, targetY);
        if (currentX < targetX) currentX = Math.min(currentX + speed, targetX);
        if (currentX > targetX) currentX = Math.max(currentX - speed, targetX);

        // 목표 지점에 도달하면 다음 경로 지점으로 이동
        if (currentX === targetX && currentY === targetY) {
            currentPoint++;
        }

        requestAnimationFrame(animate); // 다음 프레임 요청
    }
    animate(); // 애니메이션 시작
}

// --- 이벤트 리스너 ---

// '사다리 생성' 버튼 클릭 이벤트
startBtn.addEventListener("click", function () {
    if(isAnimating) return;

    // ★ 버그 수정: 결과 박스의 스타일을 초기화하는 로직
    const resultBoxes = resultOutputsContainer.querySelectorAll('.result-box');
    resultBoxes.forEach(box => {
        box.style.backgroundColor = ''; // 배경색을 원래대로
        box.style.border = '2px solid #e0e0e0'; // 테두리도 원래대로
    });
    
    // 서버에 사다리 데이터 생성을 요청 (fetch API 사용)
    const contextPath = document.getElementById('game-container').dataset.contextPath;
    fetch(`${contextPath}/ladder?players=${numPlayers}`)
        .then(response => {
            if (!response.ok) {
                throw new Error('서버와 통신하여 사다리 데이터를 가져오는 데 실패했습니다.');
            }
            return response.json(); // 응답을 JSON 형태로 파싱
        })
        .then(data => {
            // 서버로부터 받은 데이터로 사다리 그림
            ladderData = data;
            drawLadder(ladderData);
            console.log(`${numPlayers}명으로 서버에서 사다리 생성 완료`, ladderData);
        })
        .catch(error => {
            console.error("Error:", error);
            alert(error.message);
        });
});

// --- 페이지 로드 시 초기 실행 ---
initializeGame();

