package controller;

import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;
import model.RouletteData;

@WebServlet("/roulette")
public class RouletteController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String[] options = request.getParameterValues("option");

        if (options == null || options.length == 0) 
        {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "옵션이 없습니다.");
            return;
        }

        Random rand = new Random();
        String winner = options[rand.nextInt(options.length)];

        RouletteData result = new RouletteData(winner);
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(new Gson().toJson(result));
    }
}