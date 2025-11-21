package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/mainpage")
public class MainPageController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 세션 가져오기 (로그인 여부 확인)
        HttpSession session = request.getSession(false);

        // 세션이 없거나, 로그인 성공 시 저장한 "userID" 속성이 없으면 로그인 페이지로 이동
        if (session == null || session.getAttribute("userID") == null)
        {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?error=session");
            return;
        }

        // 로그인 되어 있다면 Welcome.jsp로 이동
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/MainPage.jsp");
        dispatcher.forward(request, response);
    }
}