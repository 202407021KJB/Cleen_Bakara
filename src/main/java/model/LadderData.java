package model;

import java.util.List;

public class LadderData 
{
    private List<Integer> xPositions;
    private List<Rung> rungs;

    public static class Rung 
    {
        public int y;
        public int col;

        public Rung(int y, int col) 
        {
            this.y = y;
            this.col = col;
        }
    }

    public LadderData(List<Integer> xPositions, List<Rung> rungs)
    {
        this.xPositions = xPositions;
        this.rungs = rungs;
    }

    public List<Integer> getXPositions()
    {
        return xPositions;
    }

    public List<Rung> getRungs() 
    {
        return rungs;
    }
}