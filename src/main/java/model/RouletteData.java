package model;

public class RouletteData {
    private String winner;

    public RouletteData(String winner) 
    {
        this.winner = winner;
    }

    public String getWinner() 
    {
        return winner;
    }

    public void setWinner(String winner) 
    {
        this.winner = winner;
    }
}