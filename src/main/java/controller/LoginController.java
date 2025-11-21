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

        // 해당 모드는 개발자 모드(그냥 로그인만 눌러도 로그인 됨)
        if (true)
        {
            HttpSession session = request.getSession();
            session.setAttribute("saveID", "devID");
            session.setAttribute("savePW", "devPW");
            session.setAttribute("saveName", "개발자");
            session.setAttribute("userID", "devID"); // WelcomeController 호환성 추가
            session.setAttribute("cash", 999999);    // 임시 캐시 설정
            response.sendRedirect(request.getContextPath() + "/mainpage");
            return;
        }

        // 입력값 받아오기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");
        
        // DAO를 사용하여 회원 조회
        MemberDAO dao = new MemberDAO();
        Member member = dao.findMember(userID, userPW);

        // 로그인 유효성 로직
        if (member != null)
        {
            // 로그인 성공 시
            HttpSession session = request.getSession();
            
            // 세션 속성 통일화
            session.setAttribute("userID", member.getUserID()); 
            session.setAttribute("saveName", member.getNickname());
            session.setAttribute("cash", member.getCash()); 

            // 일일 로그인 캐시 지급
            GamecashManager.giveDailyLoginReward(member, session);

            // 로그인이 성공 했으니 메인 홈페이지로 리다이렉션
            response.sendRedirect(request.getContextPath() + "/mainpage");
        }
        else
        {
            // 로그인 실패시 로그인 페이지로 리다이렉션
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?error=1");
        }
    }
}