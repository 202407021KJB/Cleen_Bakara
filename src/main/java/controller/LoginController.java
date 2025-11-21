package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.Member;
import model.MemberDAO;
import controller.GamecashManager;

@WebServlet("/login")
public class LoginController extends HttpServlet
{
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        // 1. 입력값 받아오기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");
        
        MemberDAO dao = new MemberDAO();

        // 2. 관리자 계정 (admin / 1234) 특수 처리
        // 사용자가 'admin' / '1234'로 로그인을 시도하면, 
        // 서버 메모리에 해당 계정이 없을 경우 즉시 생성하여 로그인 가능하게 함
        if ("admin".equals(userID) && "1234".equals(userPW)) 
        {
            if (dao.findMemberByID("admin") == null) {
                Member admin = new Member("admin", "1234", "관리자");
                admin.setCash(9999999); // 테스트용 캐시
                dao.addMember(admin);
            }
        }

        // 3. DAO를 사용하여 회원 조회
        // (관리자면 위에서 생성되었으므로 조회 성공, 일반 회원은 가입되어 있다면 조회 성공)
        Member member = dao.findMember(userID, userPW);

        // 4. 로그인 유효성 확인
        if (member != null)
        {
            // 로그인 성공 시
            HttpSession session = request.getSession();
            
            // 세션 속성 설정
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