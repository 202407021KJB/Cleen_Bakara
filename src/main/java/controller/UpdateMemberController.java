package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import model.MemberDAO;

// 매핑
@WebServlet("/updateMember")
public class UpdateMemberController extends HttpServlet 
{
	/** POST 요청 방식
	 *  로그인, 회원가입, 회원탈퇴, 회원 정보 수정에서 다루어질 방식
	 *  GET 방식과 달리 POST 방식은 주소창에 정보가 노출되지 않음
	 *  보안성을 위해 사용하는 것
	 */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        request.setCharacterEncoding("UTF-8");
        
        // 접속한 사용자의 세션을 가져옴, (false)는 없으면 NULL을 반환 하라는 뜻
        HttpSession session = request.getSession(false);
        
        // 로그인을 하지 않은 사용자라면 로그인 페이지로 리다이렉션
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
            return;
        }

        /** 수정될 부분의 조건
         * userID   -> session으로 요청 : 조건(아이디가 이 사람인 경우)
         * userPW   -> request 요청 : 바꿀 내용
         * nickname -> request 요청 : 바꿀 내용
         */
        String userID = (String) session.getAttribute("userID");
        String newPw = request.getParameter("userPW");
        String newNickname = request.getParameter("nickname");

        // DAO 호출
        MemberDAO dao = new MemberDAO();
        
        // DB에서 해당 사용자의 아이디, 비번, 닉네임의 변경을 시킴
        // 변경 됐다면 true 반환, 안 지워졌다면 false 반환 
        boolean isUpdated = dao.updateMemberInfo(userID, newPw, newNickname);

        // 결과 처리
        if (isUpdated) {
            // 닉네임을 바꾼 사용자를 위해 세션 정보도 새로 갱신
        	// 이 처리를 하지 않으면 DB의 내용은 바뀌겠으나 화면 상에는 처리 X
            session.setAttribute("saveName", newNickname);
            
            // 수정 성공 알림과 함께 마이페이지로 이동
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('회원 정보가 수정되었습니다.'); location.href='" + request.getContextPath() + "/view/MyInfo.jsp';</script>");
        } else {
            response.getWriter().println("<script>alert('수정 실패'); history.back();</script>");
        }
    }
}