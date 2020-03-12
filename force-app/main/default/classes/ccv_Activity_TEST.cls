@isTest

private class ccv_Activity_TEST {
    @isTest
    private static void basic_test_date () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = '2018-01-01';
        act0.name = '0';
        act0.typeDate ();
        ccv_Activity act1 = new ccv_Activity ();
        act1.activityDate = '2019-01-01';
        act1.name = '1';
        act1.typeDate ();
        ccv_Activity act2 = new ccv_Activity ();
        act2.activityDate = '2019-02-02';
        act2.name = '2';
        act2.typeDate ();
        List < ccv_Activity > actList = new List < ccv_Activity > ();
        actList.add ( act0 );
        actList.add ( act1 );
        actList.add ( act2 );

        System.assertEquals ( '0', actList[0].name );
        actList.sort ();
        // assert that we sorted dates descending
        System.assertEquals ( '2', actList[0].name );
        System.assertEquals ( '1', actList[1].name );
        System.assertEquals ( '0', actList[2].name );

    }

    @isTest
    private static void basic_test_date_no_switch () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = '2019-02-01';
        act0.name = '0';
        act0.typeDate ();
        ccv_Activity act1 = new ccv_Activity ();
        act1.activityDate = '2019-01-01';
        act1.name = '1';
        act1.typeDate ();
        List < ccv_Activity > actList = new List < ccv_Activity > ();
        actList.add ( act0 );
        actList.add ( act1 );

        actList.sort ();

        // assert that we nothing changed because they were already sorted
        System.assertEquals ( '0', actList[0].name );
        System.assertEquals ( '1', actList[1].name );

    }

    @isTest
    private static void basic_test_date_equals () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = '2019-02-01';
        act0.name = '0';
        act0.typeDate ();
        ccv_Activity act1 = new ccv_Activity ();
        act1.activityDate = '2019-02-01';
        act1.name = '1';
        act1.typeDate ();
        List < ccv_Activity > actList = new List < ccv_Activity > ();
        actList.add ( act0 );
        actList.add ( act1 );

        actList.sort ();

        // assert that we nothing changed
        System.assertEquals ( '0', actList[0].name );
        System.assertEquals ( '1', actList[1].name );

    }

    @isTest
    private static void basic_test_datetime () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = '2018-01-01 00:00:00';
        act0.name = '0';
        act0.typeDate ();
        ccv_Activity act1 = new ccv_Activity ();
        act1.activityDate = '2019-01-01T00:00:00Z';
        act1.name = '1';
        act1.typeDate ();
        ccv_Activity act2 = new ccv_Activity ();
        act2.activityDate = '2019-02-02T00:00:00Z';
        act2.name = '2';
        act2.typeDate ();
        List < ccv_Activity > actList = new List < ccv_Activity > ();
        actList.add ( act0 );
        actList.add ( act1 );
        actList.add ( act2 );

        System.assertEquals ( '0', actList[0].name );
        actList.sort ();
        // assert that we sorted dates descending
        System.assertEquals ( '2', actList[0].name );
        System.assertEquals ( '1', actList[1].name );
        System.assertEquals ( '0', actList[2].name );

    }

    @isTest
    private static void basic_test_null () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = null;
        act0.name = '0';
        act0.typeDate ();

        System.assertEquals ( 'NULL', act0.activityDateType );

    }

    @isTest
    private static void basic_test_unknown () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = 'BADDATEVALUE';
        act0.name = '0';
        act0.typeDate ();

        System.assertEquals ( 'Unknown', act0.activityDateType );

    }

    @isTest
    private static void basic_test_badvalue_sort () {

        ccv_Activity act0 = new ccv_Activity ();
        act0.activityDate = 'Jumbple';
        act0.name = '0';
        act0.typeDate ();
        ccv_Activity act1 = new ccv_Activity ();
        act1.activityDate = null;
        act1.name = '1';
        act1.typeDate ();
        ccv_Activity act2 = new ccv_Activity ();
        act2.activityDate = '2019-02-02T00:00:00Z';
        act2.name = '2';
        act2.typeDate ();
        List < ccv_Activity > actList = new List < ccv_Activity > ();
        actList.add ( act0 );
        actList.add ( act1 );
        actList.add ( act2 );

        System.assertEquals ( '0', actList[0].name );
        actList.sort ();
        // assert that we didn't change any sorting
        System.assertEquals ( '0', actList[0].name );
        System.assertEquals ( '1', actList[1].name );
        System.assertEquals ( '2', actList[2].name );

    }
}