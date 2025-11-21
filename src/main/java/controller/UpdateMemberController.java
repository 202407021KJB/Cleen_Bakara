package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.MemberDAO;

@WebServlet("/updateMember")
public class UpdateMemberController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
            return;
        }

        String userID = (String) session.getAttribute("userID");
        String newPw = request.getParameter("userPW");
        String newNickname = request.getParameter("nickname");

        MemberDAO dao = new MemberDAO();
        boolean isUpdated = dao.updateMemberInfo(userID, newPw, newNickname);

        if (isUpdated) {
            // 세션 정보도 갱신 (닉네임이 바뀌었으므로)
            session.setAttribute("saveName", newNickname);
            
            // 수정 성공 알림과 함께 마이페이지로 이동
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('회원 정보가 수정되었습니다.'); location.href='" + request.getContextPath() + "/view/MyInfo.jsp';</script>");
        } else {
            response.getWriter().println("<script>alert('수정 실패'); history.back();</script>");
        }
    }
}