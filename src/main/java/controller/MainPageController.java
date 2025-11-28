package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

// 매핑
@WebServlet("/mainpage")
public class MainPageController extends HttpServlet 
{
	/** GET 요청 방식
	 *  메인 페이지는 사용자가 URL을 직접 입력하거나, 메뉴 링크를 클릭해서 들어옴
	 *  GET 방식을 사용해야 함
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
    {

        /** Controller가 View에게 화면 출력을 요청하는 부분
         * RequestDispatcher를 사용하여 서버 내부에서 /view/MainPage.jsp로 제어권 넘김
         * sendRedirect 대신 forward를 사용한 이유
         * 1. /mainpage 라는 것은 변함이 없음 -> 주소창을 유지한 채로 서버 내부에서 몰래 화면만 전환
         * 2. forward는 요청 객체가 살아있어 데이터를 그대로 가져가는 것이 가능
         * 	  sendRedirect는 새로운 요청을 보내는 형식 -> 데이터를 다 잃어버림
         */
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/MainPage.jsp");
        dispatcher.forward(request, response);
    }
}