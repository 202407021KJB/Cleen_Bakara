package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 세션 종료
        HttpSession session = request.getSession(false);
        if (session != null) 
        {
            session.invalidate();
        }

        // 로그인 페이지로 리다이렉트
        response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp");
    }
}