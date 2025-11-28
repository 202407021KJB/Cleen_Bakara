package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.regex.Pattern;
import model.Member;
import model.MemberDAO;
import controller.GamecashManager;

@WebServlet("/signup")
public class SignUpController extends HttpServlet
{
    // 유효성 검사를 위한 정규 표현식 패턴 생성
    private static final Pattern ID_PATTERN = Pattern.compile("^(?=.*[a-zA-Z])[a-zA-Z0-9]{4,16}$");
    private static final Pattern PW_PATTERN = Pattern.compile("^(?=.*[!@#$%^&*()_+{}\\[\\]:;<>,.?~\\\\/-]).{6,20}$");
    private static final Pattern NICKNAME_PATTERN = Pattern.compile("^[a-zA-Z가-힣]{2,12}$");

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        // getParameter로 입력값을 받아오기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");
        String nickname = request.getParameter("nickname");

        // 유효성 검사 진행
        if (!ID_PATTERN.matcher(userID).matches() || 
            !PW_PATTERN.matcher(userPW).matches() || 
            !NICKNAME_PATTERN.matcher(nickname).matches()) 
        {
        	// 걸린다면 오류 문구가 뜸
            response.sendRedirect(request.getContextPath() + "/view/SignUpPage.jsp?error=validation");
            return;
        }

        MemberDAO dao = new MemberDAO();
        
        /*** 아이디 중복 체크
         * findMemberByID로 중복된 아이디가 있는지 조회
         * 존재를 한다면, "이미 존재하는 아이디입니다." alert 창 출력
         * history.back()으로 이전 페이지로 다시 이동(회원가입 창으로)
         */
        if (dao.findMemberByID(userID) != null) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('이미 존재하는 아이디입니다.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        /*** 닉네임 중복 체크
         * findMemberByNickname으로 중복된 닉네임이 있는지 조회
         * 존재를 한다면, "이미 존재하는 별명입니다." alert 창 출력
         * history.back() 으로 이전 페이지로 다시 이동(회원가입 창으로)
         */
        if (dao.findMemberByNickname(nickname) != null) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('이미 존재하는 별명입니다.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        // 위의 중복 체크를 통과 하였다면 멤버 객체에 아이디, 비번, 닉네임 저장
        Member newMember = new Member(userID, userPW, nickname);
        
        // DB에 저장
        dao.addMember(newMember);

        // 보너스 캐시 지급 및 세션 처리
        HttpSession session = request.getSession();
        GamecashManager.giveJoinReward(newMember, session);

        // 세션에 로그인 정보 저장
        session.setAttribute("userID", userID);
        session.setAttribute("saveName", nickname);  
        session.setAttribute("cash", newMember.getCash()); 

        // 회원가입 완료 후 로그인 페이지로 이동
        response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?msg=join_success");
    }
}