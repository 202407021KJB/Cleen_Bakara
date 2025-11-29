console.log("LadderGame.js 로드됨 ✅ (v9.0 - Final Polish)");

// =================================================================================
// 1. CONFIG & DOM ELEMENTS
// =================================================================================

// [구성] 기본 캔버스 및 요소 크기 정의
//   - BASE_CANVAS_WIDTH/HEIGHT: 사다리 게임 캔버스의 기준 해상도
//   - BASE_BOX_SIZE: 플레이어 및 결과 상자의 기준 크기 (PC 기준)
//   - BASE_FONT_SIZE: 텍스트의 기준 폰트 크기
//   - BASE_MARGIN_TOP/BOTTOM: 상단(플레이어), 하단(결과) 박스 배치를 위한 기준 마진
const BASE_CANVAS_WIDTH = 800;
const BASE_CANVAS_HEIGHT = 400;
const BASE_BOX_SIZE = 80; // Base size for PC
const BASE_FONT_SIZE = 16;
const BASE_MARGIN_TOP = 100; // Margin is now based on the fixed box size
const BASE_MARGIN_BOTTOM = 100;

// [DOM] HTML 요소 참조: 게임 UI와 상호작용하기 위한 DOM 요소들을 가져옵니다.
const gameContainer = document.getElementById("game-container"); // 게임 전체 컨테이너
const ladderContainer = document.getElementById("ladder-container"); // 사다리 및 플레이어/결과 박스 컨테이너
const canvas = document.getElementById("ladderCanvas"); // 사다리 라인 그리기용 캔버스
const ctx = canvas.getContext("2d"); // 캔버스 2D 렌더링 컨텍스트
const betInput = document.getElementById("betAmount"); // 베팅 금액 입력 필드
const cashDisplay = document.getElementById("my-cash"); // 현재 캐시 표시 요소
const replayBtn = document.getElementById("replay-btn"); // '다시하기' 버튼

// [게임 데이터]
//   - ANIMAL_COUNT: JSP에서 전달받은 참가 동물 수 (사다리 라인 수)
//   - ALL_ANIMALS: 모든 가능한 동물 이름 목록
//   - GAME_ANIMALS: 현재 게임에 사용될 동물 이름 목록
//   - ladderData: 서버로부터 받은 사다리 구조 데이터 (가로줄 정보)
//   - isAnimating: 사다리 애니메이션이 진행 중인지 여부를 나타내는 플래그
const ANIMAL_COUNT = parseInt(gameContainer.dataset.animalCount, 10);
const ALL_ANIMALS = ["돼지", "코끼리", "원숭이", "사자", "호랑이", "기린", "하마", "악어", "펭귄", "판다"];
const GAME_ANIMALS = ALL_ANIMALS.slice(0, ANIMAL_COUNT);
let ladderData = null; // 서버에서 받아올 사다리 데이터
let isAnimating = false; // 애니메이션 진행 여부 플래그


// =================================================================================
// 2. LAYOUT ENGINE
// =================================================================================

// [기능] 게임 요소들의 레이아웃 및 크기 조정
//   - 화면 크기에 따라 캔버스, 플레이어 박스, 결과 박스 등의 크기와 위치를 동적으로 조정합니다.
//   - 반응형 디자인을 위해 컨테이너 너비를 기준으로 스케일을 계산합니다.
function layoutEngine() {
    const containerWidth = gameContainer.offsetWidth; // 게임 컨테이너의 현재 너비
    // 스케일 계산: 컨테이너 너비가 기준 너비보다 작으면 축소, 아니면 최대 1배
    const scale = Math.min(1, containerWidth / BASE_CANVAS_WIDTH); 

    const scaledCanvasWidth = BASE_CANVAS_WIDTH * scale; // 스케일된 캔버스 너비
    const scaledCanvasHeight = BASE_CANVAS_HEIGHT * scale; // 스케일된 캔버스 높이
    
    const boxSize = BASE_BOX_SIZE; // [FIX] 박스 크기는 이제 고정 (스케일되지 않음)
    const scaledFontSize = Math.max(10, BASE_FONT_SIZE * scale); // 최소 폰트 크기 10px 보장

    // 여백 스케일 조정: 박스 크기에 비례하여 여백 유지
    const scaledMarginTop = boxSize * 1.2;
    const scaledMarginBottom = boxSize * 1.2;

    // 사다리 컨테이너 스타일 설정: 캔버스 및 박스들을 포함하는 부모 요소
    ladderContainer.style.position = 'relative';
    ladderContainer.style.width = `${scaledCanvasWidth}px`;
    ladderContainer.style.height = `${scaledCanvasHeight}px`;
    ladderContainer.style.marginTop = `${scaledMarginTop}px`;
    ladderContainer.style.marginBottom = `${scaledMarginBottom}px`;
    ladderContainer.style.marginLeft = 'auto'; // 중앙 정렬
    ladderContainer.style.marginRight = 'auto'; // 중앙 정렬

    // 캔버스 스타일 설정: 부모 컨테이너에 맞춰 100% 채움
    canvas.style.width = '100%';
    canvas.style.height = '100%';

    // 각 세로 라인의 X 좌표 계산
    const xPositions = [];
    const stepX = scaledCanvasWidth / (ANIMAL_COUNT + 1); // 라인 간 간격
    for (let i = 0; i < ANIMAL_COUNT; i++) {
        xPositions.push(stepX * (i + 1));
    }

    const playerBoxes = ladderContainer.querySelectorAll('.player-box'); // 플레이어 (상단) 박스
    const resultBoxes = ladderContainer.querySelectorAll('.result-box'); // 결과 (하단) 박스

    // 플레이어 박스 위치 및 스타일 조정
    playerBoxes.forEach((box, i) => {
        box.style.position = 'absolute';
        box.style.width = `${boxSize}px`;
        box.style.height = `${boxSize}px`;
        box.style.fontSize = `${scaledFontSize}px`;
        box.style.left = `${xPositions[i] - (boxSize / 2)}px`; // X 좌표 중앙 정렬
        box.style.top = `-${scaledMarginTop / 2}px`; // 상단 여백 중앙 정렬
        box.style.transform = 'translateY(-50%)'; // Y축 중앙 정렬 보정
    });

    // 결과 박스 위치 및 스타일 조정
    resultBoxes.forEach((box, i) => {
        box.style.position = 'absolute';
        box.style.width = `${boxSize}px`;
        box.style.height = `${boxSize}px`;
        box.style.fontSize = `${scaledFontSize}px`;
        box.style.left = `${xPositions[i] - (boxSize / 2)}px`; // X 좌표 중앙 정렬
        box.style.bottom = `-${scaledMarginBottom / 2}px`; // 하단 여백 중앙 정렬
        box.style.transform = 'translateY(50%)'; // Y축 중앙 정렬 보정
    });
}


// =================================================================================
// 3. GAME LOGIC
// =================================================================================

// [기능] 게임 초기화: 새로운 게임을 시작할 준비를 합니다.
//   - 애니메이션 상태 초기화, 베팅 입력 활성화, '다시하기' 버튼 숨김.
//   - 기존 플레이어/결과 박스를 제거하고 캔버스를 다시 추가.
//   - ANIMAL_COUNT에 따라 플레이어 박스(버튼)와 결과 박스(div)를 동적으로 생성.
//   - 레이아웃 엔진을 호출하여 요소들의 위치를 재조정하고 캔버스를 지웁니다.
function resetGame() {
    isAnimating = false; // 애니메이션 진행 중 플래그 초기화
    betInput.disabled = false; // 베팅 입력 활성화
    replayBtn.style.display = 'none'; // '다시하기' 버튼 숨김

    ladderContainer.innerHTML = ''; // 기존 플레이어/결과 박스 제거
    ladderContainer.appendChild(canvas); // 캔버스 다시 추가 (가장 뒤로 가지 않도록)

    // 플레이어 박스 (시작 지점)와 결과 박스 (도착 지점) 생성
    for (let i = 0; i < ANIMAL_COUNT; i++) {
        const btn = document.createElement('button');
        btn.className = 'player-box'; // CSS 클래스 할당
        btn.innerText = GAME_ANIMALS[i]; // 동물 이름 표시
        btn.onclick = () => startGame(i); // 클릭 시 게임 시작 함수 호출
        ladderContainer.appendChild(btn);

        const div = document.createElement('div');
        div.className = 'result-box'; // CSS 클래스 할당
        div.innerText = '?'; // 초기 결과는 '?'
        ladderContainer.appendChild(div);
    }
    
    layoutEngine(); // 동적으로 생성된 요소들의 레이아웃 재조정
    ctx.clearRect(0, 0, canvas.width, canvas.height); // 캔버스 내용 지우기
}

// [기능] 게임 시작: 사용자의 베팅을 처리하고 서버에 게임 실행을 요청합니다.
//   - 베팅 금액 유효성 검사 및 사용자 확인.
//   - 애니메이션 플래그 설정 및 UI 요소 비활성화.
//   - 서버(LadderController)에 AJAX 요청을 보내 사다리 데이터를 받습니다.
//   - 받은 데이터를 바탕으로 사다리를 그리고, 선택된 경로를 애니메이션으로 표시합니다.
//   - 게임 결과에 따라 UI(캐시, 메시지)를 업데이트합니다.
function startGame(pickIndex) {
    if (isAnimating) return; // 애니메이션 중이면 중복 실행 방지
    const betValue = parseInt(betInput.value, 10); // 베팅 금액 파싱
    const currentCash = parseInt(cashDisplay.innerText.replace(/,/g, ''), 10); // 현재 보유 캐시 파싱
    
    // 베팅 금액 유효성 검사
    if (isNaN(betValue) || betValue <= 0) { alert("베팅 금액을 올바르게 입력하세요."); return; }
    if (betValue > currentCash) { alert("보유 캐시보다 많이 베팅할 수 없습니다."); return; }
    if (!confirm(`'${GAME_ANIMALS[pickIndex]}'에 ${betValue.toLocaleString()}원을 베팅하시겠습니까?`)) { return; }
    
    isAnimating = true; // 애니메이션 시작 플래그 설정
    document.querySelectorAll('.player-box').forEach(b => b.disabled = true); // 플레이어 선택 버튼 비활성화
    betInput.disabled = true; // 베팅 입력 필드 비활성화
    
    const contextPath = gameContainer.dataset.contextPath; // JSP에서 전달받은 컨텍스트 경로
    
    // 서버(LadderController)에 게임 데이터 요청 (AJAX)
    fetch(`${contextPath}/ladder?players=${ANIMAL_COUNT}&pick=${pickIndex}&bet=${betValue}`)
        .then(res => res.json()) // JSON 응답 파싱
        .then(data => {
            if (data.error) throw new Error(data.error); // 서버에서 에러가 반환된 경우 처리
            
            ladderData = data.ladderData; // 서버로부터 받은 사다리 구조 데이터
            const results = data.results; // 서버로부터 받은 최종 결과 목록 ('당첨', '꽝')
            
            // 결과 박스 업데이트
            const resultBoxes = ladderContainer.querySelectorAll('.result-box');
            resultBoxes.forEach((box, i) => { box.innerText = results[i]; });
            
            drawLadder(ladderData); // 캔버스에 사다리 그리기
            const pathResult = findPath(pickIndex, ladderData); // 선택된 플레이어의 사다리 경로 계산
            
            // 사다리 경로 애니메이션 실행
            animatePath(pathResult, () => {
                const finalResult = data.results[pathResult.endCol]; // 최종 도착 지점의 결과
                
                // 결과에 따른 UI 효과
                if (finalResult === '당첨') {
                    resultBoxes[pathResult.endCol].style.backgroundColor = '#2ecc71'; // 당첨 시 배경색 변경
                }
                resultBoxes[pathResult.endCol].style.transform += ' scale(1.1)'; // 결과 박스 확대 효과
                
                setTimeout(() => {
                    alert(data.message.replace("localhost8080 내용:", "").trim()); // 결과 메시지 알림 (불필요한 텍스트 제거)
                    cashDisplay.innerText = data.currentCash.toLocaleString(); // 현재 캐시 업데이트
                    replayBtn.style.display = 'inline-block'; // '다시하기' 버튼 표시
                }, 100); // 약간의 지연 후 알림 및 UI 업데이트
            });
        })
        .catch(err => {
            console.error("Fetch Error:", err); // 에러 로깅
            alert("서버와 통신 중 오류가 발생했습니다."); // 사용자에게 에러 알림
            isAnimating = false; // 애니메이션 플래그 초기화
            document.querySelectorAll('.player-box').forEach(b => b.disabled = false); // 버튼 다시 활성화
            betInput.disabled = false; // 베팅 입력 필드 다시 활성화
        });
}

// [기능] 사다리 구조 그리기: 캔버스에 사다리 세로줄과 가로줄을 렌더링합니다.
//   - xPositions: 각 세로 라인의 X 좌표를 계산.
//   - ctx.clearRect: 이전 그림을 지워 캔버스를 깨끗하게 유지.
//   - 세로줄 그리기: ANIMAL_COUNT에 따라 정해진 간격으로 세로줄을 그립니다.
//   - 가로줄 그리기: 서버에서 받은 ladderData.rungs(가로줄 정보)를 기반으로 가로줄을 그립니다.
function drawLadder(data) {
    // 각 세로 라인의 X 좌표 계산
    const xPositions = [];
    const stepX = BASE_CANVAS_WIDTH / (ANIMAL_COUNT + 1); // 라인 간 간격
    for (let i = 0; i < ANIMAL_COUNT; i++) { xPositions.push(stepX * (i + 1)); }

    ctx.clearRect(0, 0, canvas.width, canvas.height); // 캔버스 전체 지우기
    ctx.lineWidth = 2; // 선 두께 설정
    ctx.strokeStyle = "#333"; // 선 색상 설정

    // 사다리 세로줄 그리기
    xPositions.forEach(x => {
        ctx.beginPath(); // 새로운 경로 시작
        ctx.moveTo(x, 0); // 시작점
        ctx.lineTo(x, BASE_CANVAS_HEIGHT); // 끝점
        ctx.stroke(); // 경로 그리기
    });

    // 사다리 가로줄 그리기 (서버에서 받은 데이터 기반)
    if (data && data.rungs) {
        data.rungs.forEach(r => {
            const x1 = xPositions[r.col]; // 가로줄 시작 X 좌표
            const x2 = xPositions[r.col + 1]; // 가로줄 끝 X 좌표
            ctx.beginPath(); // 새로운 경로 시작
            ctx.moveTo(x1, r.y); // 시작점 (y는 서버에서 계산된 값)
            ctx.lineTo(x2, r.y); // 끝점
            ctx.stroke(); // 경로 그리기
        });
    }
}

// [기능] 사다리 경로 계산: 특정 시작 지점(startCol)에서 사다리의 가로줄을 따라 이동하는 경로를 계산합니다.
//   - xPositions: 각 세로 라인의 X 좌표 계산.
//   - path: 사다리를 따라 이동하는 경로의 각 지점을 저장하는 배열.
//   - 서버에서 받은 가로줄(rungs) 정보를 y좌표 기준으로 정렬하여 순서대로 탐색.
//   - 경로를 따라 이동하며 현재 열(col)이 가로줄과 만나면 다음 열로 이동하여 경로를 기록.
//   - 최종적으로 도착한 열(endCol)과 전체 경로(path)를 반환합니다.
function findPath(startCol, data) {
    // 각 세로 라인의 X 좌표 계산 (drawLadder와 동일)
    const xPositions = [];
    const stepX = BASE_CANVAS_WIDTH / (ANIMAL_COUNT + 1);
    for (let i = 0; i < ANIMAL_COUNT; i++) { xPositions.push(stepX * (i + 1)); }

    const path = [[xPositions[startCol], 0]]; // 시작 지점 (캔버스 상단)
    let col = startCol; // 현재 위치한 세로 라인 (열)
    
    if (data && data.rungs) {
        // 가로줄(rungs)을 y좌표 기준으로 정렬하여 아래로 내려가면서 탐색
        const sortedRungs = data.rungs.sort((a, b) => a.y - b.y);
        
        sortedRungs.forEach(r => {
            // 현재 열(col)에서 가로줄을 만나면 반대편 열로 이동
            if (r.col === col) { // 현재 열의 오른쪽으로 가로줄이 있는 경우
                path.push([xPositions[col], r.y]); // 현재 열에서 가로줄 시작점 기록
                col = col + 1; // 다음 열로 이동
                path.push([xPositions[col], r.y]); // 다음 열에서 가로줄 끝점 기록
            } else if (r.col === col - 1) { // 현재 열의 왼쪽으로 가로줄이 있는 경우
                path.push([xPositions[col], r.y]); // 현재 열에서 가로줄 시작점 기록
                col = col - 1; // 이전 열로 이동
                path.push([xPositions[col], r.y]); // 이전 열에서 가로줄 끝점 기록
            }
        });
    }
    path.push([xPositions[col], BASE_CANVAS_HEIGHT]); // 최종 도착 지점 (캔버스 하단)
    return { path, endCol: col }; // 계산된 경로와 최종 열 반환
}

// [기능] 사다리 경로 애니메이션: 계산된 경로를 따라 빨간색 선을 움직여 보여줍니다.
//   - totalLength: 전체 경로의 길이를 미리 계산.
//   - requestAnimationFrame을 사용하여 부드러운 애니메이션 구현.
//   - step 함수: 타임스탬프를 기반으로 애니메이션 진행도(progress)를 계산.
//   - drawLadder(ladderData)를 호출하여 기본 사다리 구조를 다시 그린 후, 경로를 따라 빨간 선을 그립니다.
//   - 애니메이션이 끝나면 콜백 함수를 실행하여 최종 결과를 처리합니다.
function animatePath(result, callback) {
    const { path } = result; // 계산된 경로
    let totalLength = 0;
    // 전체 경로 길이 계산
    for (let i = 0; i < path.length - 1; i++) {
        const [x1, y1] = path[i], [x2, y2] = path[i + 1];
        totalLength += Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    }
    let startTime = null; // 애니메이션 시작 시간

    function step(timestamp) {
        if (!startTime) startTime = timestamp;
        const progress = (timestamp - startTime) / 1500; // 1.5초 동안 애니메이션 진행
        const distanceToDraw = progress * totalLength; // 현재까지 그려야 할 거리

        drawLadder(ladderData); // 기본 사다리 구조 다시 그리기 (이전에 그려진 애니메이션 지우기 효과)
        
        ctx.beginPath(); // 새로운 경로 시작
        ctx.lineWidth = 4; // 애니메이션 선 두께
        ctx.strokeStyle = 'red'; // 애니메이션 선 색상
        
        let distanceTraveled = 0; // 현재까지 이동한 거리
        // 경로를 따라 선을 그리기
        for (let i = 0; i < path.length - 1; i++) {
            const [x1, y1] = path[i], [x2, y2] = path[i + 1];
            const segmentLength = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2)); // 현재 구간 길이
            ctx.moveTo(x1, y1); // 현재 구간 시작점으로 이동

            if (distanceTraveled + segmentLength > distanceToDraw) {
                // 현재 구간 내에서 애니메이션을 멈춰야 하는 경우
                const fraction = (distanceToDraw - distanceTraveled) / segmentLength;
                const stopX = x1 + (x2 - x1) * fraction;
                const stopY = y1 + (y2 - y1) * fraction;
                ctx.lineTo(stopX, stopY); // 부분적으로 선 그리기
                break; // 애니메이션 종료
            } else {
                ctx.lineTo(x2, y2); // 현재 구간 끝까지 선 그리기
                distanceTraveled += segmentLength; // 이동 거리 누적
            }
        }
        ctx.stroke(); // 그려진 선 표시

        // 애니메이션이 아직 진행 중이면 다음 프레임 요청
        if (progress < 1) {
            requestAnimationFrame(step);
        } else {
            if (callback) callback(); // 애니메이션 완료 후 콜백 함수 실행
        }
    }
    requestAnimationFrame(step); // 애니메이션 시작
}

// [기능] 게임 재설정 처리: 사용자가 새로운 동물 수로 게임을 다시 시작하고자 할 때 호출됩니다.
//   - 입력된 동물 수의 유효성을 검사합니다 (2 ~ maxAnimals).
//   - 유효성 검사를 통과하면, 새로운 'animalCount' 파라미터와 함께 LadderPage.jsp로 페이지를 리로드합니다.
//   - 모바일 환경에서는 최대 동물 수를 제한하여 UI가 깨지지 않도록 합니다.
function handleRegenerate() {
    const newCountInput = document.getElementById("animalCountInput"); // 새 동물 수 입력 필드
    let newCount = parseInt(newCountInput.value, 10); // 입력 값 파싱
    const isMobile = window.innerWidth <= 768; // 모바일 여부 확인
    const maxAnimals = isMobile ? 3 : 10; // 모바일 최대 동물 수 제한 (PC는 10)
    
    // 입력된 동물 수 유효성 검사
    if (isNaN(newCount) || newCount < 2 || newCount > maxAnimals) {
        alert(`2에서 ${maxAnimals} 사이의 올바른 동물 수를 입력하세요.`);
        // 유효하지 않은 경우, 입력 필드 값을 유효 범위 내로 조정
        newCountInput.value = Math.max(2, Math.min(newCount, maxAnimals));
        return;
    }
    const contextPath = gameContainer.dataset.contextPath; // 컨텍스트 경로
    // 새로운 animalCount 파라미터와 함께 페이지 리로드 (캐싱 방지를 위해 ver 파라미터 추가)
    window.location.href = `${contextPath}/view/LadderPage.jsp?animalCount=${newCount}&ver=${Date.now()}`;
}

// [기능] 모바일 환경 제한 적용: 화면 너비가 특정 값(768px) 이하일 경우 모바일로 간주하여,
//   - 'animalCountInput'의 최대값(max)을 3으로 제한합니다.
//   - 현재 입력된 동물 수가 3보다 크면 3으로 조정하고, 페이지를 재로드하여 제한을 적용합니다.
function applyMobileLimitations() {
    const isMobile = window.innerWidth <= 768; // 현재 화면이 모바일 크기인지 확인
    if (isMobile) {
        const animalCountInput = document.getElementById("animalCountInput");
        const maxAnimals = 3; // 모바일 환경에서의 최대 동물 수
        if (animalCountInput) {
            animalCountInput.max = maxAnimals; // 입력 필드의 최대값 설정
            // 현재 설정된 동물 수가 모바일 최대값보다 크면 조정 및 페이지 재로드
            if (parseInt(animalCountInput.value, 10) > maxAnimals) {
                animalCountInput.value = maxAnimals;
                handleRegenerate(); // 페이지 재로드하여 새 설정 적용
            }
        }
    }
}

// =================================================================================

// 4. INITIALIZATION & EVENT LISTENERS

// =================================================================================



// [초기화] 페이지 로드 시 실행되는 함수들

//   - applyMobileLimitations: 모바일 환경에 따른 게임 제한을 적용합니다.

//   - resetGame: 게임 UI를 초기 상태로 설정하고, 필요한 요소를 동적으로 생성합니다.

applyMobileLimitations(); // 모바일 환경 제한 적용

resetGame(); // 게임 초기화



// [이벤트 리스너] 사용자 상호작용 및 화면 변화에 반응하는 이벤트 리스너 설정

//   - replayBtn 클릭 시: resetGame 함수를 호출하여 게임을 다시 시작합니다.

//   - window.resize 시: layoutEngine 함수를 호출하여 화면 크기 변화에 맞춰 UI를 재조정합니다.

replayBtn.onclick = resetGame; // '다시하기' 버튼 클릭 이벤트

window.addEventListener('resize', layoutEngine); // 화면 크기 변경 시 레이아웃 재조정
