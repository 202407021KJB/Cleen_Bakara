package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.Member;
import model.MemberDAO;

@WebServlet("/join")
public class JoinController extends HttpServlet
{
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        String passwd = request.getParameter("passwd");
        String nickname = request.getParameter("nickname");

        // 서버 콘솔 출력
        System.out.println("회원가입 정보: " + userId + ", " + nickname);

        // Application 영역에 사용자 정보 저장 (DB 대체)
        ServletContext context = getServletContext();
        context.setAttribute("savedId", userId);
        context.setAttribute("savedPw", passwd);
        context.setAttribute("savedNick", nickname);

        response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp");
    }
}