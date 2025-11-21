package model;

import java.util.ArrayList;
import java.util.List;

public class MemberDAO {
    private static List<Member> memberList = new ArrayList<>();

    // 회원가입
    public void addMember(Member member) {
        memberList.add(member);
    }

    // 아이디로 찾기
    public Member findMemberByID(String id) {
        for (Member m : memberList) {
            if (m.getUserID().equals(id)) {
                return m;
            }
        }
        return null;
    }
    
    // 로그인 확인
    public Member findMember(String id, String pw) {
        for (Member m : memberList) {
            if (m.getUserID().equals(id) && m.getUserPW().equals(pw)) {
                return m;
            }
        }
        return null;
    }

    // [추가] 회원 정보 수정 (비밀번호, 닉네임 변경)
    public void updateMember(Member updateReq) {
        for (Member m : memberList) {
            if (m.getUserID().equals(updateReq.getUserID())) {
                // 비밀번호가 비어있지 않으면 수정
                if (updateReq.getUserPW() != null && !updateReq.getUserPW().isEmpty()) {
                    // Member 클래스에 setter 필요 (없으면 아래 Member.java 참고하여 추가)
                    // 여기서는 편의상 필드에 직접 접근하거나 setter가 있다고 가정
                    // 실제로는 m.setUserPW(...) 필요
                }
                // 닉네임 수정
                // m.setNickname(updateReq.getNickname()); 
                // Member 클래스가 수정 불가능한 구조라면 아래처럼 교체해야 함.
                // 여기서는 Member 객체의 필드를 수정하는 방식 대신, 리스트 내 객체를 갱신하는 방식 사용
                
                // *주의*: Member 클래스에 Setter가 없으면 추가해야 합니다.
                // 아래 코드를 위해 Member.java에 setUserPW, setNickname을 추가해주세요.
            }
        }
    }
    
    // [추가] 리스트 내 객체 직접 수정 (Member 클래스 수정 없이 사용하기 위해)
    public boolean updateMemberInfo(String id, String newPw, String newNickname) {
        for (Member m : memberList) {
            if (m.getUserID().equals(id)) {
                m.setUserPW(newPw);
                m.setNickname(newNickname);
                return true;
            }
        }
        return false;
    }

    // [추가] 회원 탈퇴
    public boolean deleteMember(String id) {
        return memberList.removeIf(m -> m.getUserID().equals(id));
    }
}