package controller;

import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.*;
import model.LadderData;

@WebServlet("/ladder")
public class LadderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int players = Integer.parseInt(request.getParameter("players"));
        List<Integer> xPositions = new ArrayList<>();
        List<LadderData.Rung> rungs = new ArrayList<>();

        int ladderLeft = 50, ladderRight = 450;
        int stepX = (ladderRight - ladderLeft) / (players - 1);

        for (int i = 0; i < players; i++) 
        {
            xPositions.add(ladderLeft + i * stepX);
        }

        Random rand = new Random();
        for (int y = 70; y < 350; y += 30) 
        {
            for (int i = 0; i < players - 1; i++) 
            {
                if (rand.nextBoolean()) 
                {
                    rungs.add(new LadderData.Rung(y, i));
                }
            }
        }

        LadderData data = new LadderData(xPositions, rungs);

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(new Gson().toJson(data));
    }
}