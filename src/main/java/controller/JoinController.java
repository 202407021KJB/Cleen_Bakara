package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.Member;
import model.MemberDAO;

@WebServlet("/join")
public class JoinController extends HttpServlet {
    private MemberDAO dao = new MemberDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String userId = request.getParameter("userId");
        String passwd = request.getParameter("passwd");

        Member member = new Member(userId, passwd);
        dao.addMember(member); // Model 사용 (회원 저장)

        response.sendRedirect("view/LoginForm.jsp");
    }
}