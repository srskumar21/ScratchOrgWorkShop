/****************************************************************************************************************************
*** Class Name          	 :  LicenseFileDownload 
*** Author                   :  Hanumanth A
*** Class Created Date     	 :	11/12/2019
*		Modified Date        :	
*		Modified By          :  
******************************************************************************************************************************/
public class LicenseFileDownload {
    public LicenseFileDownload(ApexPages.StandardController std) {
    }

    @RemoteAction
    public static String downloadFile(String accountNumber) {
        system.debug('accountNumber'+accountNumber);
        HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:Veterinarysoftware_License_File?accountNumber=' + EncodingUtil.urlEncode(accountNumber, 'UTF-8'));
		req.setMethod('GET');
        req.setTimeout(1 * 60 * 1000);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return EncodingUtil.base64Encode(res.getBodyAsBlob());
    }
}