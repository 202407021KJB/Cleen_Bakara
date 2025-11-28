package model;

import java.sql.*;
import java.time.LocalDate;

public class MemberDAO {
	
	/** DB 연결 정보(MySQL)
	 *  DB_URL : 데이터베이스에 연결하기 위한 접속 URL
	 *  DB_ID  : MySQL에서 사용되는 아이디
	 *  DB_PW  : MySQL에서 사용되는 비밀번호
	 *  해당 ID, PW로 접속해야 가능
	 */
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bakara_db?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8";
    private static final String DB_ID = "root";
    private static final String DB_PW = "1234";

    // DB 연결 객체 가져오기
    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(DB_URL, DB_ID, DB_PW);
    }

    // 회원가입
    public void addMember(Member member) {
        String sql = "INSERT INTO member (userID, userPW, nickname, cash, lastLoginDate) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, member.getUserID());
            pstmt.setString(2, member.getUserPW());
            pstmt.setString(3, member.getNickname());
            pstmt.setInt(4, member.getCash());
            
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

    // 아이디로 회원 찾기 (중복 검사용)
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

    // 닉네임으로 회원 찾기 (중복 검사용)
    public Member findMemberByNickname(String nickname) {
        String sql = "SELECT * FROM member WHERE nickname = ?";
        Member member = null;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nickname);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    member = new Member(
                        rs.getString("userID"),
                        rs.getString("userPW"),
                        rs.getString("nickname")
                    );
                    // 중복 확인용이므로 나머지 정보는 필요 시 세팅
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return member;
    }
    
    // 로그인 확인용 (아이디 & 비번)
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
            return result > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 캐시 및 접속일 업데이트
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