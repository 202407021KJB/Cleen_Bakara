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
        request.setCharacterEncoding("UTF-8");

        String inputId = request.getParameter("userId");
        String inputPw = request.getParameter("passwd");

        ServletContext context = getServletContext();
        String savedId = (String) context.getAttribute("savedId");
        String savedPw = (String) context.getAttribute("savedPw");
        String savedNick = (String) context.getAttribute("savedNick");

        if (savedId != null && savedPw != null
                && savedId.equals(inputId) && savedPw.equals(inputPw))
        {
            HttpSession session = request.getSession();
            session.setAttribute("userId", savedId);
            session.setAttribute("nickname", savedNick);

            response.sendRedirect(request.getContextPath() + "/view/Welcome.jsp");
        }
        else
        {
            response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp?error=1");
        }
    }
}