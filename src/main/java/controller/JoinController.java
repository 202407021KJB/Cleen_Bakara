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

        // 세션으로 저장
        HttpSession session = request.getSession();
        session.setAttribute("savedId", userId);
        session.setAttribute("savedPw", passwd);
        session.setAttribute("savedNick", nickname);

        // DAO 저장 (DB 응용 시 사용)
        MemberDAO dao = new MemberDAO();
        dao.addMember(new Member(userId, passwd, nickname));

        // 회원가입 후, 로그인 페이지로 리다이렉션
        response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp");
    }
}