package model;

import java.sql.*;
import java.time.LocalDate;

public class MemberDAO {
	
	/** DB 연결 정보
	 * DB_URL : DB 담긴 주소
	 * DB_ID  : MySQL 아이디임
	 * DB_PW  : MySQL 비밀번호임
	 */
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bakara_db?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8";
    private static final String DB_ID = "root";
    private static final String DB_PW = "1234";

    // DB 연결 객체 가져오기
    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(DB_URL, DB_ID, DB_PW);
    }

    // MySQL 이용 했습니다
    // 회원가입
    public void addMember(Member member) {
        String sql = "INSERT INTO member (userID, userPW, nickname, cash, lastLoginDate) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, member.getUserID());
            pstmt.setString(2, member.getUserPW());
            pstmt.setString(3, member.getNickname());
            pstmt.setInt(4, member.getCash());
            
            // LocalDate -> java.sql.Date 변환
            if (member.getLastLoginDate() != null) {
                pstmt.setDate(5, java.sql.Date.valueOf(member.getLastLoginDate()));
            } else {
                pstmt.setDate(5, null);
            }
            
            pstmt.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 아이디로 회원 찾을 것임
    public Member findMemberByID(String id) {
        String sql = "SELECT * FROM member WHERE userID = ?";
        Member member = null;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, id);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    member = new Member(
                        rs.getString("userID"),
                        rs.getString("userPW"),
                        rs.getString("nickname")
                    );
                    member.setCash(rs.getInt("cash"));
                    
                    // java.sql.Date -> LocalDate 변환
                    Date date = rs.getDate("lastLoginDate");
                    if (date != null) {
                        member.setLastLoginDate(date.toLocalDate());
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return member;
    }
    
    // 로그인 확인용
    public Member findMember(String id, String pw) {
        String sql = "SELECT * FROM member WHERE userID = ? AND userPW = ?";
        Member member = null;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, id);
            pstmt.setString(2, pw);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    member = new Member(
                        rs.getString("userID"),
                        rs.getString("userPW"),
                        rs.getString("nickname")
                    );
                    member.setCash(rs.getInt("cash"));
                    
                    Date date = rs.getDate("lastLoginDate");
                    if (date != null) {
                        member.setLastLoginDate(date.toLocalDate());
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return member;
    }

    // 회원 정보 업데이트
    public boolean updateMemberInfo(String id, String newPw, String newNickname) {
        String sql = "UPDATE member SET userPW = ?, nickname = ? WHERE userID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, newPw);
            pstmt.setString(2, newNickname);
            pstmt.setString(3, id);
            
            int result = pstmt.executeUpdate();
            return result > 0; // 1개 이상 수정되면 성공
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // [캐시 및 접속일 업데이트] (중요! 게임 결과 저장용 메서드 추가 필요)
    // GamecashManager 등에서 호출할 수 있도록 캐시 업데이트 기능이 필요합니다.
    // 기존 코드에서는 객체만 수정하면 되었지만, DB 버전에서는 반드시 'UPDATE' 쿼리를 날려야 저장됩니다.
    public void updateCashAndDate(Member member) {
        String sql = "UPDATE member SET cash = ?, lastLoginDate = ? WHERE userID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, member.getCash());
            if (member.getLastLoginDate() != null) {
                pstmt.setDate(2, java.sql.Date.valueOf(member.getLastLoginDate()));
            } else {
                pstmt.setDate(2, null);
            }
            pstmt.setString(3, member.getUserID());
            
            pstmt.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 회원 탈퇴
    public boolean deleteMember(String id) {
        String sql = "DELETE FROM member WHERE userID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, id);
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}