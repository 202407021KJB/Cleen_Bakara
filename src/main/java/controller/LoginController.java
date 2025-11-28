package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.Member;
import model.MemberDAO;
import controller.GamecashManager;

// 매핑
@WebServlet("/login")
public class LoginController extends HttpServlet
{
	/** POST 요청 방식
	 *  로그인, 회원가입, 회원탈퇴, 회원 정보 수정에서 다루어질 방식
	 *  GET 방식과 달리 POST 방식은 주소창에 정보가 노출되지 않음
	 *  보안성을 위해 사용하는 것
	 */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        // getParameter로 입력값을 받아오기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");
        
        MemberDAO dao = new MemberDAO();

        /*** 테스트를 위한 관리자 계정 생성
         * admin, 1234로 로그인을 시도하면
         * DB에 자동적으로 아이디, 비번이 저장됨
         * 캐시도 9999999로 지급
         */
        if ("admin".equals(userID) && "1234".equals(userPW)) 
        {
            if (dao.findMemberByID("admin") == null) 
            {
                Member admin = new Member("admin", "1234", "관리자");
                admin.setCash(9999999); // 테스트용 캐시
                dao.addMember(admin);
            }
        }

        // 회원 조회
        Member member = dao.findMember(userID, userPW);

        // 로그인 유효성 확인
        if (member != null)
        {
            // 세션 처리
            HttpSession session = request.getSession();
            
            // 세션에 로그인 정보 저장
            session.setAttribute("userID", member.getUserID()); 
            session.setAttribute("saveName", member.getNickname());
            session.setAttribute("cash", member.getCash()); 

            // 일일 로그인 캐시 지급
            GamecashManager.giveDailyLoginReward(member, session);

            // 메인 홈페이지로 이동
            response.sendRedirect(request.getContextPath() + "/mainpage");
        }
        else
        {
            // 로그인 실패 시 (아이디/비번 불일치)
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?error=1");
        }
    }
}