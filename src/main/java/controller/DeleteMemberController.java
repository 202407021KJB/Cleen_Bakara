package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.MemberDAO;

@WebServlet("/deleteMember")
public class DeleteMemberController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
            return;
        }

        String userID = (String) session.getAttribute("userID");
        
        MemberDAO dao = new MemberDAO();
        boolean isDeleted = dao.deleteMember(userID);

        if (isDeleted) {
            // 세션 무효화 (로그아웃 처리)
            session.invalidate();
            
            // 탈퇴 완료 알림 후 메인으로
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('회원 탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다.'); location.href='" + request.getContextPath() + "/mainpage';</script>");
        } else {
            response.getWriter().println("<script>alert('탈퇴 실패'); history.back();</script>");
        }
    }
}