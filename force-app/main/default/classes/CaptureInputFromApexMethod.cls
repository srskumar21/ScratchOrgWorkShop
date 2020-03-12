/**************************************************************************************************
*** Trigger Name           : CaptureInputFromApexMethod
*** Class Description      : Capture all the method parameters passed and concatenate and return as a string
*** Author                 : Coreflex Solutions
*** Class Created Date     : 
*** Configurable Parameters:
*        End Point URL     :
*        Custom Labels Used:
*        Custom Object Used: 
*** Change Management      :
*        Change #          : 
*        Change Description:
*        Modified Date     :
*        Modified By       :
**************************************************************************************************/
public class CaptureInputFromApexMethod {
    public static string captureAndReturnInput(String datatype1, String input1, String datatype2, String input2,
                                               String datatype3, String input3, String datatype4, String input4,
                                               String datatype5, String input5)
    {
        String concatenatedInput = '';
        
        if(input1 != null){
            concatenatedInput = concatenatedInput + '{' + datatype1 + ': ' + input1 + '}';
        }
        if(input2 != null){
            concatenatedInput = concatenatedInput + '{' + datatype2 + ': ' + input2 + '}';
        }
        if(input3 != null){
            concatenatedInput = concatenatedInput + '{' + datatype3 + ': ' + input3 + '}';
        }
        if(input4 != null){
            concatenatedInput = concatenatedInput + '{' + datatype4 + ': ' + input4 + '}';
        }
        if(input5 != null){
            concatenatedInput = concatenatedInput + '{' + datatype5 + ': ' + input5 + '}';
        }
        return concatenatedInput;
    }
}