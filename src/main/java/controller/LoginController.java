package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.Member;
import model.MemberDAO;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    private MemberDAO dao = new MemberDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String inputId = request.getParameter("userId");
        String inputPw = request.getParameter("passwd");

        Member member = dao.findMember(inputId, inputPw);

        if (member != null) 
        {
            // 로그인 성공 시 세션 생성
            HttpSession session = request.getSession();
            session.setAttribute("userId", member.getUserId());

            // 메인 페이지로 이동 (Controller 통해)
            response.sendRedirect(request.getContextPath() + "/welcome");
        } 
        else 
        {
            // 로그인 실패 시
            response.sendRedirect("view/LoginForm.jsp?error=1");
        }
    }
}