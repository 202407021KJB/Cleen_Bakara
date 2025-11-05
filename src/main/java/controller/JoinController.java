package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/join")
public class JoinController extends HttpServlet {
	protected void doPost(HttpServletRequest request
					      , HttpServletResponse response)
	
	throws ServletException, IOException
	{
		request.setCharacterEncoding("utf-8");
		String userId = request.getParameter("userId");
		String passwd = request.getParameter("passwd");
		
		ServletContext context = getServletContext();
		context.setAttribute("saveId", userId);
		context.setAttribute("savePw", passwd);
		
		response.sendRedirect("view/LoginForm.jsp");
	}
}
