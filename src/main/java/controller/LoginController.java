package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet
{
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        // 이 로직은 개발자 모드 로직입니다.
        // 최종 배포 시에는 false 처리 또는 코드 삭제 부탁드립니다.
        if (true)
        {
            HttpSession session = request.getSession();
            session.setAttribute("saveID", "devID");
            session.setAttribute("savePW", "devPW");
            session.setAttribute("saveName", "개발자");

            response.sendRedirect(request.getContextPath() + "/view/Welcome.jsp");
            return;
        }

        // 로그인 화면에서 입력한 아이디, 비밀번호 값 받기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");

        // 회원가입 시 저장되었던 정보를 가져오는 로직
        HttpSession session = request.getSession();

        String saveID = (String) session.getAttribute("saveID");
        String savePW = (String) session.getAttribute("savePW");
        String saveName = (String) session.getAttribute("saveName");

        // 로그인 유효성 검사 -> 저장값과 입력값을 비교함
        // 일치한다면 메인 페이지로 이동, 불일치시 로그인 폼 전환
        if (saveID != null && savePW != null
                && saveID.equals(userID) && savePW.equals(userPW))
        {
            response.sendRedirect(request.getContextPath() + "/view/Welcome.jsp");
        }
        else
        {
            response.sendRedirect(request.getContextPath() + "/view/LoginForm.jsp?error=1");
        }
    }
}