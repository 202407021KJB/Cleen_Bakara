package model;

import java.util.ArrayList;
import java.util.List;

// 회원 정보 값을 메모리에 저장하는 용도
// DB 추가시 사용 예정입니다
public class MemberDAO {
    private static List<Member> memberList = new ArrayList<>();

    // 회원가입
    public void addMember(Member member) 
    {
        memberList.add(member);
    }

    // 회원 찾기는 아이디로만 찾기(안전성)
    public Member findMemberByID(String id)
    {
        for (Member m : memberList) 
        {
            if (m.getUserID().equals(id)) 
            {
                return m;
            }
        }
        return null;
    }
    
    // 로그인
    public Member findMember(String id, String pw) 
    {
        for (Member m : memberList) 
        {
            if (m.getUserID().equals(id) && m.getUserPW().equals(pw)) 
            {
                return m;
            }
        }
        return null;
    }
}