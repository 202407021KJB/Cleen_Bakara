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

        // 입력값 받기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");
        String nickname = request.getParameter("nickname");

        // 위에서 입력된 값을 저장해두는 곳 -> 로그인 유효성 검사에서 사용될 변수들임
        HttpSession session = request.getSession();
        session.setAttribute("saveID", userID);
        session.setAttribute("savePW", userPW);
        session.setAttribute("saveName", nickname);

        // DAO 저장 (DB 응용 시 사용)
        MemberDAO dao = new MemberDAO();
        dao.addMember(new Member(userID, userPW, nickname));

        // 회원가입 후, 로그인 페이지로 리다이렉션
        response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp");
    }
}