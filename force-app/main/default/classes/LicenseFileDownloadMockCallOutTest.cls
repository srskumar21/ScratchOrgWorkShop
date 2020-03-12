/****************************************************************************************************************************
*** Class Name          	 :  LicenseFileDownloadMockCallOutTest 
*** Author                   :  Hanumanth A
*** Class Created Date     	 :	11/12/2019
*		Modified Date        :	
*		Modified By          :  
******************************************************************************************************************************/
@isTest
global class LicenseFileDownloadMockCallOutTest implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        
         HttpResponse response = new HttpResponse();
         response.setHeader('Content-Type', 'application/json');
         response.setBody('N04000');
         response.setStatusCode(200);
        return response;
    }

}