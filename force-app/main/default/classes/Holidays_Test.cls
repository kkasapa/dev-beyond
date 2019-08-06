@isTest
public class Holidays_Test {

    @testsetup
    public static void testData(){
        
        Holiday h = new holiday(); 
        
        h.Name = 'Test_4thJuly'; 
        
        h.ActivityDate = Date.newInstance(2017, 7, 4); 
        
        h.IsAllDay = true; 
        
        insert h; 
        
        Holiday mday = new holiday(); 
        
        mday.Name = 'Test_MemorialDay'; 
        
        mday.ActivityDate = Date.newInstance(2017, 7, 4); 
        
        mday.IsAllDay = true; 
        
        mday.IsRecurrence = true; 
        
        mday.RecurrenceDayOfMonth = 04; 
        
        mday.RecurrenceMonthOfYear = 'July';
        
        mday.RecurrenceStartDate = Date.newInstance(2017, 7, 4);
        
        mday.RecurrenceType = 'RecursYearly';
            
        insert mday; 
    }
    
    public testmethod static void testHoliday(){
        
       String day = Holidays.dayOftheWeek( Date.newInstance(2017,4,20)); 
        System.assertEquals('Thursday', day );
        
        String dayT = Holidays.dayOftheWeek( DateTime.newInstance(2017,4,20)); 
        System.assertEquals('Thursday', dayT );
        
        List<Holiday> holidaylist = Holidays.getHolidays();
        
        System.assertEquals(holidaylist.size(), 2);
        
        //System.assertEquals(holidaylist[0].Name, 'Test_4thJuly');
        
        Boolean isholiday =  Holidays.isHolidayOrWeekend(holidayList,Date.newInstance(2017,4,20));
        
        boolean fourthJuly = Holidays.isHolidayOrWeekend(holidayList, Date.newInstance(2017,7,4)); 
        
        System.assertEquals(isholiday,false); 
        System.assertEquals(fourthJuly,true); 
        
        integer sunday = Holidays.dayOfTheWeekmask('Sunday');
        
        System.assertEquals(1, sunday); 
        
        integer saturday = Holidays.dayOfTheWeekmask('Saturday');
        
        System.assertEquals(2, Saturday); 
        
         integer monday = Holidays.dayOfTheWeekmask('Monday');
        
        System.assertEquals(0, Monday); 
        
        integer tuesday = Holidays.dayOfTheWeekmask('Tuesday');
        
        System.assertEquals(0, Tuesday); 
        
        integer wednesday = Holidays.dayOfTheWeekmask('Wednesday');
        
        System.assertEquals(0, wednesday); 
        
        integer sunday2 = Holidays.holidaysInWeekDays('sunday');
        
        System.assertEquals(1, sunday2); 
        
        Boolean isweekend = Holidays.isWeekEnd('sunday');
        
        System.assert(isweekend); 
        
        integer month =  Holidays.monthOfTheYear('April'); 
        
        System.assertEquals(month, 4); 
        
        month =  Holidays.monthOfTheYear('August'); 
        
        System.assertEquals(month, 8); 
        
         month =  Holidays.monthOfTheYear('September'); 
        
        System.assertEquals(month, 9); 
        
        
         month =  Holidays.monthOfTheYear('October'); 
        
        System.assertEquals(month, 10);
        
         month =  Holidays.monthOfTheYear('November'); 
        
        System.assertEquals(month, 11);
        
         month =  Holidays.monthOfTheYear('December'); 
        
        System.assertEquals(month, 12);
        
        Map<String,Holiday> holidaymap = Holidays.getHolidaysMap();
        
        Date workingDay = Holidays.getNextWorkingDay(HolidayMap, Date.newInstance(2017, 07, 04));
        
        System.assertEquals(Date.newInstance(2017, 07, 05),workingDay); 
        
        integer holidaysInWeekDays =  Holidays.holidaysInWeekDays('Monday');
        
          System.assertEquals(holidaysInWeekDays,1); 
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Tuesday');
        
          System.assertEquals(holidaysInWeekDays,1); 
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Wednesday');
        
          System.assertEquals(holidaysInWeekDays,1); 
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Friday');
        
          System.assertEquals(holidaysInWeekDays,3); 
        
          holidaysInWeekDays =  Holidays.holidaysInWeekDays('Saturday');
        
          System.assertEquals(holidaysInWeekDays,2); 
        
    } 
}