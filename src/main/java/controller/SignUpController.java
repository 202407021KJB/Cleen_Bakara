package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.regex.Pattern;
import model.Member;
import model.MemberDAO;
import controller.GamecashManager;

@WebServlet("/signup")
public class SignUpController extends HttpServlet
{
    // 정규 표현식 패턴 만들기
    private static final Pattern ID_PATTERN = Pattern.compile("^(?=.*[a-zA-Z])[a-zA-Z0-9]{4,16}$");
    private static final Pattern PW_PATTERN = Pattern.compile("^(?=.*[!@#$%^&*()_+{}\\[\\]:;<>,.?~\\\\/-]).{6,20}$");
    private static final Pattern NICKNAME_PATTERN = Pattern.compile("^[a-zA-Z가-힣]{2,12}$");

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        // 입력값 받아오기
        String userID = request.getParameter("userID");
        String userPW = request.getParameter("userPW");
        String nickname = request.getParameter("nickname");

        // 위에 만든 패턴을 통해 유효성 검사
        if (!ID_PATTERN.matcher(userID).matches() || 
            !PW_PATTERN.matcher(userPW).matches() || 
            !NICKNAME_PATTERN.matcher(nickname).matches()) 
        {
            // 실패시, 회원가입 페이지로 리다이렉션
            response.sendRedirect(request.getContextPath() + "/view/SignUpPage.jsp?error=validation");
            return;
        }

        // DAO에 데이터 저장
        MemberDAO dao = new MemberDAO();
        Member newMember = new Member(userID, userPW, nickname);
        dao.addMember(newMember);

        // 회원가입 보너스 캐시 제공
        HttpSession session = request.getSession();
        GamecashManager.giveJoinReward(newMember, session);

        // 세션 저장(아이디와 닉네임만)
        // 비밀번호는 보안상의 이유로 저장하지 않음
        session.setAttribute("saveID", userID);
        session.setAttribute("saveName", nickname);  
        // 캐시 지급 후에 캐시 값 저장
        session.setAttribute("cash", newMember.getCash()); 

        // 회원가입 후 로그인 페이지로 리다이렉션
        response.sendRedirect(request.getContextPath() + "/view/LoginPage.jsp?msg=join_success");
    }
}