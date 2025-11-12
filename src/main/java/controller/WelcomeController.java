package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/welcome")
public class WelcomeController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 세션 가져오기 (로그인 여부 확인)
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            // 세션이 없으면 로그인 페이지로 이동
            response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp?error=session");
            return;
        }

        // 로그인 되어 있다면 Welcome.jsp로 이동
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/Welcome.jsp");
        dispatcher.forward(request, response);
    }
}