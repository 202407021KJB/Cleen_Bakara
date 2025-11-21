package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/mainpage")
public class MainPageController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 로그인 되어 있다면 Welcome.jsp로 이동
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/MainPage.jsp");
        dispatcher.forward(request, response);
    }
}