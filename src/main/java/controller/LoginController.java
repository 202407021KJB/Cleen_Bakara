package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet {
	protected void doPost(HttpServletRequest request
						  , HttpServletResponse response)
	
	throws ServletException, IOException
	{
		request.setCharacterEncoding("utf-8");
		String inputId = request.getParameter("userId");
		String inputPw = request.getParameter("passwd");
		
		ServletContext context = getServletContext();
		String saveId = (String) context.getAttribute("saveId");
		String savePw = (String) context.getAttribute("savePw");
		
		if (saveId != null
			&& savePw != null
			&& saveId.equals(inputId)
			&& savePw.equals(inputPw)
			)
		{
			response.sendRedirect("view/Welcome.jsp");
		}
		else
		{
			response.sendRedirect("view/LoginForm.jsp?error=1");
		}
	}
}
