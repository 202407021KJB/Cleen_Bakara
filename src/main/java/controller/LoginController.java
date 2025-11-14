package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.Member;
import model.MemberDAO;

@WebServlet("/login")
public class LoginController extends HttpServlet
{
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        /// 개발자 모드 : 배포 시에는 제거 or false 처리 해야 함
        if (true)
        {
            HttpSession session = request.getSession();
            session.setAttribute("userId", "user1");
            session.setAttribute("nickname", "개발자모드");
            response.sendRedirect(request.getContextPath() + "/view/Welcome.jsp");
            return;
        }
    	
        request.setCharacterEncoding("UTF-8");

        String inputId = request.getParameter("userId");
        String inputPw = request.getParameter("passwd");

        // 세션으로 저장
        HttpSession session = request.getSession();
        String savedId = (String) session.getAttribute("savedId");
        String savedPw = (String) session.getAttribute("savedPw");
        String savedNick = (String) session.getAttribute("savedNick");

        // 로그인 검사
        if (savedId != null && savedPw != null
            && savedId.equals(inputId)
            && savedPw.equals(inputPw))
        {
            session.setAttribute("userId", savedId);
            session.setAttribute("nickname", savedNick);

            // 성공시 메인 페이지로 리다이렉션
            response.sendRedirect(request.getContextPath() + "/view/Welcome.jsp");
        }
        else
        {
        	// 실패시 로그인 페이지로 리다이렉션
            response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp?error=1");
        }
    }
}