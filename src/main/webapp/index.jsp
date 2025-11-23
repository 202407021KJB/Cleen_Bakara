<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 프로젝트가 실행되면 즉시 메인 페이지 컨트롤러로 이동시킵니다.
    // "mainpage"는 MainPageController에 설정된 주소(@WebServlet("/mainpage"))입니다.
    response.sendRedirect("mainpage");
%>