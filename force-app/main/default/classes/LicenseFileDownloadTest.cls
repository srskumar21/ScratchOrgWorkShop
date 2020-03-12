/****************************************************************************************************************************
*** Class Name          	 :  LicenseFileDownloadTest 
*** Author                   :  Hanumanth A
*** Class Created Date     	 :	11/12/2019
*		Modified Date        :	
*		Modified By          :  
******************************************************************************************************************************/
@isTest
Public  class LicenseFileDownloadTest {
    static testmethod void test1(){
        Test.setMock(HttpCalloutMock.class, new LicenseFileDownloadMockCallOutTest());
        string test1= 'N04000';
        LicenseFileDownload.downloadFile(test1);
    }
}