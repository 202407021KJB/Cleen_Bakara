package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.MemberDAO;

// 매핑
@WebServlet("/deleteMember")
public class DeleteMemberController extends HttpServlet 
{
	/** POST 요청 방식
	 *  로그인, 회원가입, 회원탈퇴, 회원 정보 수정에서 다루어질 방식
	 *  GET 방식과 달리 POST 방식은 주소창에 정보가 노출되지 않음
	 *  보안성을 위해 사용하는 것
	 */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
    	// 접속한 사용자의 세션을 가져옴, (false)는 없으면 NULL을 반환 하라는 뜻
        HttpSession session = request.getSession(false);
        
        /** 세션이 없거나, 세션은 있는데 userID가 없을 경우
         *  => 로그인을 안한 사용자라는 의미
         *  로그인 페이지로 리다이렉션, return으로 빠져나옴
         */
        if (session == null || session.getAttribute("userID") == null) 
        {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
            return;
        }

        /* 여기서부터는 탈퇴 처리 방법 */
        
        // 세션에 들어있던 사용자의 userID 값을 꺼내옴
        String userID = (String) session.getAttribute("userID");
        
        // DAO 호출
        MemberDAO dao = new MemberDAO();
        
        // DB에서 해당 userID가 지워지게 시킴
        // 지워졌다면 true 반환, 안 지워졌다면 false 반환
        boolean isDeleted = dao.deleteMember(userID);

        // 결과 처리
        if (isDeleted) 
        {
            // 세션 무효화 (로그아웃 처리)
            session.invalidate();
            
            // 탈퇴 완료 알림 후 메인으로
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('회원 탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다.'); location.href='" + request.getContextPath() + "/mainpage';</script>");
        } 
        else 
        {
            response.getWriter().println("<script>alert('탈퇴 실패'); history.back();</script>");
        }
    }
}