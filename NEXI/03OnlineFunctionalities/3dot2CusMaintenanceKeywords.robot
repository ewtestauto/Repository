*** Settings ***
Documentation  Includes keywords using in customer maintenance process defined within _*3dot2CusMaintenanceKeywords.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI\\03OnlineFunctionalities*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    String
Library    DateTime
#Library    builtin

Resource   ../Environments.robot
Resource   3dot2CusMaintenanceVariables.robot

*** Keywords ***
Find plastic for test 3.2 Cus Maintenance
    [Arguments]     ${plasticFirstNumber}
    [Documentation]  Chooses plastic card for test 3.2 Cus Maintenance and sets it as a test variable.
    ...
    ...  Usage:
    ...
    ...    - ``Find plastic for test 3.2 Cus Maintenance  ${plasticFirstNumber}``, where ${plasticFirstNumber} is first number of plastic: 4 for VISA or 5 for MasterCard.
    ...
    ...  An example:
    ...    - ``Find plastic for test 3.2 Cus Maintenance  4``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `From ISPF go to SQL query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    From ISPF go to SQL query
    Send query    SELECT B.PL_ID, A.AC_INTRL_ID, A.AC_CO_NR
          ...     FROM &{environment}[owner].DCTAC_ACCOUNT A,
          ...     &{environment}[owner].DCTPL_PLASTIC B
          ...     WHERE A.AC_INTRL_ID = B.AC_INTRL_ID
          ...     AND B.PL_CUR_STAT_CD = 'AA'
          ...     AND B.PL_CUR_STAT_RSN_CD = 'AA'
          ...     AND B.PL_ID like '${plasticFirstNumber}%'
          ...     AND B.PL_CUR_EXP_DT > '${PlCurExpDate}'
          ...     WITH UR;
    Sleep  1
    Log screen
    Send enter
    Log screen
    String found    3   29  Select Statement Browse

    ${myPlastic}=   string get  11  2
    Set test variable  ${myPlastic}

    :FOR  ${INDEX}  IN RANGE  44  47
    \   Log     ${INDEX}
    \   ${myCompanyId}=  string get  11  ${INDEX}
    \   ${status} =     Run Keyword And Return Status  Should Not Be Empty   ${myCompanyId}
    \   Log     ${status}
    \   Exit For Loop If    ${status} == True
    Set test variable  ${myCompanyId}
    Log screen

Open STAD
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens STAD screen for plastic card and sets an account number as a test variable ${myAccount}.
    ...
    ...  Usage:
    ...
    ...    - ``Open STAD ${plasticNumber}``, where ${plasticNumber} is plastic number to open in STAD.
    ...
    ...  An example:
    ...    - ``Open STAD  ${myPlastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | |  `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Fill field by label     FUNCTION    STAD
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Log screen
    ${myAccount}=  string get  5  47
    Log  ${myAccount}
    ${myAccount}=  Remove String  ${myAccount}  -  *
    Set test variable  ${myAccount}
    Log  ${myAccount}
    Log screen

Check STAD SCREEN
    [Documentation]  Checks on STAD screen Street, ZIP, City, Prov, Country. They should not be empty. Sets them as test variables.
    ...
    ...  Usage:
    ...
    ...    - ``Check STAD SCREEN``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Open STAD` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    String found    3   1   STATEMENT ADDRESS MAINT.
    ${myStreet}=   string get  19  19
    Set test variable  ${myStreet}
    Should not be empty   ${myStreet}
    ${myZip}=   string get  21  8
    Set test variable  ${myZIP}
    Should not be empty   ${myZip}
    ${myCity}=   string get  21  27
    Set test variable  ${myCity}
    Should not be empty   ${myCity}
    ${myProv}=   string get  21  62
    Set test variable  ${myProv}
    Should not be empty   ${myProv}
    ${myCountry}=   string get  22  12
    Should not be empty   ${myCountry}
    Set test variable  ${myCountry}
    Log screen

New Address
    [Documentation]  Changes on STAD screen Street, ZIP, City, Prov, Country on new values taken from test variables.
    ...
    ...  Usage:
    ...
    ...    - ``New Address``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file; |
    ...  | | `Open STAD` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Log screen
    Fill field by label   STREET   ${myNewStreet}
    Fill field by label   ZIP   ${myNewZIP}
    Fill field by label   CITY   ${myNewCity}
    Fill field by label   PROV   ${myNewProv}
    Fill field by label   COUNTRY   ${myNewCountry}
    Log screen
    Send enter
    Log screen
    String found   3   51  ACTION SUCCESSFUL
    Sleep  1
    Log screen
    Send pf3

Check New Adrress
    [Documentation]  Checks address (Street, ZIP, City, Prov, Country) after changes on STAD screen.
    ...  It should be the same as test variables.
    ...
    ...  Usage:
    ...
    ...    - ``Check New Adrress``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file; |
    ...  | | `New Address`, `Open STAD` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Log screen
    String found    3   1   STATEMENT ADDRESS MAINT.
    ${myCheckNewStreet}=   string get  19   19
    Set test variable  ${myCheckNewStreet}
    Should Be Equal   ${myCheckNewStreet}   ${myNewStreet}
    ${myCheckNewZIP}=   string get  21   8
    Set test variable  ${myCheckNewZIP}
    Should Be Equal   ${myCheckNewZIP}   ${myNewZIP}
    ${myCheckNewCity}=   string get  21   27
    Set test variable  ${myCheckNewCity}
    Should Be Equal   ${myCheckNewCity}   ${myNewCity}
    ${myCheckNewProv}=   string get  21   62  2
    Set test variable  ${myCheckNewProv}
    Should Be Equal   ${myCheckNewProv}   ${myNewProv}
    ${myCheckNewCountry}=   string get  22   12  3
    Set test variable  ${myCheckNewCountry}
    Should Be Equal   ${myCheckNewCountry}   ${myNewCountry}
    Log screen

Open CUSTOMER SERVICE
# TODO in the next Sprint to use - Customer by letter
    [Documentation]  Opens CUSTOMER SERVICE.
    ...
    ...  Usage:
    ...
    ...    - ``Open CUSTOMER SERVICE``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | |  `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Fill field by label     FUNCTION    02
    Send enter
    Log screen
    String found    3   1   CUSTOMER SERVICE
    Log screen

Open STATEMENT ADDRESS MAINT
# TODO in the next Sprint to use - Customer by letter
    [Documentation]  Opens STATEMENT ADDRESS MAINT.
    ...
    ...  Usage:
    ...
    ...    - ``Open STATEMENT ADDRESS MAINT``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Open CUSTOMER SERVICE` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Fill field by label     FUNCTION    01
    Send enter
    Log screen
    String found    3   1   CUSTOMER LOCATE
    Log screen

Check Co on CAPN
    [Arguments]  ${accountNumber}
    [Documentation]  Opens CAPN screen for account number and sets Company as a test variable.
    ...
    ...  Usage:
    ...
    ...    - ``Check Co on CAPN ${accountNumber}``, where ${accountNumber} is account number to open in CAPN.
    ...
    ...  An example:
    ...    - ``Open STAD  ${myAccount}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Fill field by label     FUNCTION    CAPN
    Fill field by label     ACCOUNT     ${accountNumber}
    Send enter
    Sleep  1
    Log screen
    String found  2  2  CAPN
    ${myCompany}=  string get  7  76  5
    Set test variable  ${myCompany}
    Log  ${myCompany}
    Log screen
    Send pf3

Check on table ADDR_X_ACCT_TB
    [Arguments]     ${accountNumber}  ${addrEffDate}
    [Documentation]  Takes data from table ADDR_X_ACCT_TB for choosen ACCT_ID and ADDR_EFF_DATE which is equal online date.
    ...  Checks ADDR_EXP_DATE. It should be equal to '31.12.2799'.
    ...  Sets ADDR_STREET_ID and ADDR_BLDG_NBR_HASH as test variables.
    ...
    ...  Usage:
    ...
    ...    - ``Check on table ADDR_X_ACCT_TB  ${accountNumber}  ${addrEffDate}``,
    ...  where ${accountNumber} is ACCT_ID for account and ${addrEffDate} is ADDR_EFF_DATE equal online date.
    ...
    ...  An example:
    ...    - ``Check on table ADDR_X_ACCT_TB  ${myAccount}  ${online_date}``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Send string     r
    Send enter
    Send string     8
    Send enter
    Send string     4
    Send enter
    Send string     3
    Send enter
    String found    3   25  Enter, Execute and Explain SQL
    Send query    SELECT ADDR_EXP_DATE, ADDR_STREET_ID, ADDR_BLDG_NBR_HASH
          ...     FROM &{environment}[owner].ADDR_X_ACCT_TB
          ...     WHERE ACCT_ID = '${accountNumber}'
          ...     AND ADDR_EFF_DATE = '${addrEffDate}'
          ...     WITH UR;
    Sleep  1
    Log screen
    Send enter
    Log screen
    String found    3   29  Select Statement Browse
    ${myAddrExpDate}=   string get  11  2
    Log  ${myAddrExpDate}
    Should be equal   ${myAddrExpDate}  31.12.2799
    ${myAddrStreetId}=   string get  11  16
    Set test variable  ${myAddrStreetId}
    ${myAddrBldgNbrHash}=   string get  11  48
    Set test variable  ${myAddrBldgNbrHash}
    Log  ${myAddrExpDate}
    Log  ${myAddrStreetId}
    Log  ${myAddrBldgNbrHash}
    Log screen
    Send pf3
    Send pf3
    Log screen
    String found    3   21  SQL Prototyping, Execution and Analysis

Check on table ADDRESS_TB
    [Arguments]     ${addrStreetId}  ${addrBldgNbrHash}
    [Documentation]  Takes data from table ADDRESS_TB for choosen ADDR_STREET_ID and ADDR_BLDG_NBR_HASH.
    ...  Checks ADDR_LINE_1, CITY_NAME, STATE_NAME_OR_CD, CNTRY_CD_5. They should be equal test variables for new address.
    ...  Checks LST_MAINT_DATE which should be equal calendar date of changes.
    ...  Returns data in descending order by  ADDR_UPDT_TS DESC.
    ...
    ...  Usage:
    ...
    ...    - ``Check on table ADDRESS_TB  ${addrStreetId}  ${addrBldgNbrHash}``,
    ...  where ${addrStreetId}  ${addrBldgNbrHash} are taken from ADDR_X_ACCT_TB.
    ...
    ...  An example:
    ...    - ``Check on table ADDRESS_TB  ${myAddrStreetId}  ${myAddrBldgNbrHash}``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Check on table ADDR_X_ACCT_TB` |
    ...  | Co-requisite   | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    ${myCurrentDate}=  Get current date  result_format=%d.%m.%Y
    Log  ${myCurrentDate}
    Send string     3
    Send enter
    Log screen
    String found    3   25  Enter, Execute and Explain SQL
    Send query    SELECT ADDR_LINE_1, CITY_NAME, STATE_NAME_OR_CD, CNTRY_CD_5
          ...     FROM &{environment}[owner].ADDRESS_TB
          ...     WHERE ADDR_STREET_ID = '${myAddrStreetId}'
          ...     AND ADDR_BLDG_NBR_HASH = '${myAddrBldgNbrHash}'
          ...     AND LST_MAINT_DATE = '${myCurrentDate}'
          ...     ORDER BY ADDR_UPDT_TS DESC
          ...     WITH UR;
    Sleep  1
    Log screen
    Send enter
    Log screen
    String found    3   29  Select Statement Browse
    ${myAddrLine1}=   string get  11  2
    Should be equal   ${myAddrLine1}  ${myNewStreet}
    ${myCityName}=   string get  11  43
    Should be equal   ${myCityName}  ${myNewCity}
    ${myStateNameOrCd}=   string get  11  69
    Should be equal   ${myStateNameOrCd}  ${myNewProv}
    Send pf  11
    ${myCntryCd5}=   string get  11  19
    Should be equal   ${myCntryCd5}  ${myNewCountry}
    Log screen
    Send pf3
    Send pf3
    Log screen
    String found    3   21  SQL Prototyping, Execution and Analysis


#Choose Customer by letter
# TODO in the next Sprint - Customer by letter - is not finished
 #   [Arguments]  ${letter}
  #  Fill field by label     SURNAME    ${letter}
   # Send enter
    #Log screen


