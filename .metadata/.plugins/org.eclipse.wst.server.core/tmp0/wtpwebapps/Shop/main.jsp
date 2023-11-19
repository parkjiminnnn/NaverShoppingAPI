<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="shop.DBconnect"%>
<%@ page import="shop.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>

<%
	// 한글 깨짐 방지
    request.setCharacterEncoding("UTF-8");

    // 검색 결과를 저장할 리스트
    List<Data> searchResults = new ArrayList<>();

    // POST 메서드로 요청이 왔을 때 검색 수행
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // 사용자가 입력한 검색어 가져오기
        String searchTerm = request.getParameter("searchTerm");

        // 검색어가 비어있지 않다면 API 호출
        if (searchTerm != null && !searchTerm.isEmpty()) {
            // 네이버 API 호출
            String clientId = "iE6XydOWfru4IEU74MXl";
            String clientSecret = "m9Am_QmO2k";

            String text = URLEncoder.encode(searchTerm, "UTF-8");
            String apiURL = "https://openapi.naver.com/v1/search/shop?query="+text+"&display=100";
            Map<String, String> requestHeaders = new HashMap<>();
            requestHeaders.put("X-Naver-Client-Id", clientId);
            requestHeaders.put("X-Naver-Client-Secret", clientSecret);

            // 네이버 API 호출 메서드를 통해 결과 받아오기
            searchResults = NaverShop.parseItemsArray(NaverShop.get(apiURL, requestHeaders));
        }
    }
 // 저장 버튼이 클릭되면 DB에 저장
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("saveButton") != null) {
        DBconnect.saveToDatabase(searchResults);
%>
		<!--저장확인메시지 출력  -->
		<script>  				
            alert("데이터가 성공적으로 저장되었습니다.");
        </script>
       
<%
       	}		//높은가격순
 			  	 if(request.getParameter("hpriceButton") != null){
 			  	  Collections.sort(searchResults, (data1, data2) -> Integer.compare(Integer.parseInt(data2.getLprice()), Integer.parseInt(data1.getLprice())));
 			  	 }
                  // 낮은가격순
                 if(request.getParameter("lpriceButton") != null){
                  Collections.sort(searchResults, (data1, data2) -> Integer.compare(Integer.parseInt(data1.getLprice()), Integer.parseInt(data2.getLprice())));
                 }
                  //가나다순
                  if(request.getParameter("titleButton") != null){
                  Collections.sort(searchResults, (data1, data2) -> data1.getTitle().compareTo(data2.getTitle()));

                  }
                  //브랜드순
                  if(request.getParameter("brandButton") != null){
                  	Collections.sort(searchResults, (data1, data2) -> data1.getBrand().compareTo(data2.getBrand()));
                  }
       %>

<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/table.css">
<style>
        .product-cell {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            width: 200px;
            padding: 10px;
            cursor: pointer;
        }

        .product-cell img {
            max-width: 100px;
            max-height: 100px;
        }

        table {
            border-collapse: collapse; /* 셀 간의 간격을 없애기 위해 border-collapse 속성 추가 */
            width: 100%; /* 테이블을 가득 채우도록 설정 */
        }

        table, th, td {
            border: 1px solid #ddd;
        }

        th, td {
            padding: 10px;
        }
</style>
<title>Search Page</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
	String searchTerm = request.getParameter("searchTerm");
	if(searchTerm==null) searchTerm = "";
%>
<%
    int cellCount = 0; // 각 행당 셀 개수를 세기 위한 변수 추가
    Iterator<Data> iterator = searchResults.iterator();
%>
	<form action="" method="post">
		<label for="searchTerm">검색어:</label>
	    <input type="text" id="searchTerm" name="searchTerm" value="<%=searchTerm%>" required>
        <!-- 히든 필드에 검색어 설정 -->
        <input type="hidden" id="hiddenSearchTerm" name="hiddenSearchTerm" value="<%=searchTerm%>">
	    
	    <button type="submit">검색</button>
	<!-- 저장 버튼 추가 -->
    <button type="submit" name="saveButton">검색결과저장</button>
    <button type="submit" name="basketButton" onclick="openModal()">장바구니</button><p>
    <button type="submit" name="lpriceButton">낮은가격순</button>
    <button type="submit" name="hpriceButton">높은가격순</button>
    <button type="submit" name="titleButton">가나다순</button>
    <button type="submit" name="brandButton">브랜드순</button>
	 </form>
	
<%
    // 검색 결과 출력
    if (searchResults != null && !searchResults.isEmpty()) {
%>
<!-- 검색 결과가 있을 경우 테이블로 출력 -->
<table border="1">
    <tbody>
    <% 
        int columns = 5; // 한 행당 열의 개수
        int count = 0; // 현재 열의 개수를 세기 위한 변수

        for (Data result : searchResults) { 
            // 한 행의 시작 부분
            if (count % columns == 0) {
    %>
        <tr>
    <% 
            }
            // 각 상품을 표현하는 셀
    %>
            <td class="product-cell" >
                <img alt="이미지" src="<%= result.getImage() %>" onclick="window.location='<%= result.getLink() %>'">
                <p><%= result.getTitle() %></p>
                <p><%= result.getLprice() %>원</p>
                <p><%= result.getBrand() %></p>
                 <p><a href="javascript:void(0);" onclick="addToCart('<%= result.getTitle() %>', '<%= result.getLprice() %>')">담기</a></p>
            </td>
    <%
            // 한 행의 끝 부분
            if (++count % columns == 0) {
    %>
        </tr>
    <%
            }
        }

        // 열의 개수가 columns의 배수가 아닌 경우 빈 셀로 채우기
        while (count % columns != 0) {
    %>
            <td></td>
    <%
            count++;
        }
    %>
    </tbody>
</table>
<%
    } else if ("POST".equalsIgnoreCase(request.getMethod())) {
%>
<!-- 검색 결과가 없을 경우 메시지 출력 -->
<p>검색 결과가 없습니다.</p>
<%
    }
%>
    <%-- JavaScript 추가 --%>
    <script>
        function openModal() {
            document.getElementById("myModal").style.display = "block";
            event.preventDefault(); // 폼 제출 방지
        }

        function closeModal() {
            document.getElementById("myModal").style.display = "none";
        }

        // 모달 외부를 클릭하면 모달이 닫히도록 설정
        window.onclick = function(event) {
            if (event.target == document.getElementById("myModal")) {
                document.getElementById("myModal").style.display = "none";
            }
        }
        var shoppingCart = []; // 장바구니 정보를 저장할 배열

        function addToCart(title, lprice) {
            // 장바구니에 상품 추가
            shoppingCart.push({ title: title, lprice: lprice });

            // 모달 내용 업데이트
            updateCartModal();
        }

        function updateCartModal() {
            var modalContent = document.getElementById("myModalContent");
            
            modalContent.innerHTML = "";
            // 장바구니에 있는 상품들을 모달에 추가
            for (var i = 0; i < shoppingCart.length; i++) {
                var productInfo = shoppingCart[i];
                var productElement = document.createElement("p");
                productElement.innerHTML = productInfo.title + ", 가격: " + productInfo.lprice + "원";
                modalContent.appendChild(productElement);
                
            }
            // 모달 업데이트
            document.getElementById("myModal").style.display = "block";

            // 모달 업데이트
            openModal();
        }
    </script>
    <%-- 모달 창 추가 --%>
    <div id="myModal" class="modal">
        <div class="modal-content">
            <h2>장바구니</h2>
            <span class="close" onclick="closeModal()">&times;</span>
            <!-- 모달 내용 추가 -->
            <div id="myModalContent"></div>
        </div>
    </div>

</body>
</html>
