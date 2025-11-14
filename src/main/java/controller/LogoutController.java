package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutController extends HttpServlet
{
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
    	// 세션 가져오기 (로그인 여부 확인)
        HttpSession session = request.getSession(false);

        // 세션 무효화
        if (session != null)
        {
            session.invalidate();
        }

        // 로그아웃시 로그인 페이지로 리다이렉션
        response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp");
    }
}