package model;

import java.util.ArrayList;
import java.util.List;

public class MemberDAO {
    private static List<Member> memberList = new ArrayList<>();

    // 회원가입
    public void addMember(Member member) 
    {
        memberList.add(member);
    }

    // 로그인
    public Member findMember(String id, String pw) 
    {
        for (Member m : memberList) 
        {
            if (m.getUserId().equals(id) && m.getPasswd().equals(pw)) 
            {
                return m;
            }
        }
        return null;
    }
}