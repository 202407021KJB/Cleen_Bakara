package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

// 매핑
@WebServlet("/logout")
public class LogoutController extends HttpServlet
{
	/** GET 요청 방식
	 *  로그인과 달리 GET을 사용하는 이유
	 *  로그인된 사용자의 세션을 종료(로그아웃 버튼 클릭)하는 단순한 동작
	 *  이런 경우에는 간단한 요청 방식인 GET을 선호
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
    	// 접속한 사용자의 세션을 가져옴, (false)는 없으면 NULL을 반환 하라는 뜻
        HttpSession session = request.getSession(false);

        // 세션 무효화 (로그아웃)
        if (session != null)
        {
            session.invalidate();
        }

        // 로그아웃시 로그인 페이지로 리다이렉션
        response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp");
    }
}