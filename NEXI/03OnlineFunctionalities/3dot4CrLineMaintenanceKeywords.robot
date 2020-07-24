*** Settings ***
Documentation  Includes keywords using in Adjustment process defined within _*3dot4CrLineMaintenance.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI\\03OnlineFunctionalities*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    String
Library    DateTime
#Library    builtin

Resource   ../Environments.robot
Resource   3dot4CrLineMaintenanceVariables.robot

*** Keywords ***
Find plastic for test 3.4 Cr Line Maintenance
    [Arguments]  ${date}
    [Documentation]  Chooses plastic card for test 3.4 Credit Line Maintenance with given expiration date in format dd.mm.yyyy
    ...  and sets number of plastic as a test variable ${myPlastic}, account internal ID as a test variable
    ...  ${myAccountIntID} and Company Id number for choosen plastic as a test variable ${myCompanyId}.
    ...
    ...  Usage:
    ...
    ...    - ``Find plastic for test 3.4 Cr Line Maintenance  ${date}``, where ${date} is date in format dd.mm.yyyy.
    ...
    ...  An example:
    ...    - ``Find plastic for test 3.4 Cr Line Maintenance  01.12.2021``
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
          ...     AND A.AC_CRD_TYP_CD = 'C'
          ...     AND B.PL_CUR_STAT_CD     = 'AA'
          ...     AND B.PL_CUR_STAT_RSN_CD = 'AA'
          ...     AND B.PL_CUR_EXP_DT > '${date}'
          ...     WITH UR;
    Sleep  1
    Log screen
    Send enter
    Log screen
    String found    3   29  Select Statement Browse

    ${myPlastic}=  string get  11  2
    Set test variable  ${myPlastic}

    :FOR  ${INDEX}  IN RANGE  26  29
    \   Log     ${INDEX}
    \   ${myAccountIntID}=  string get  11  ${INDEX}
    \   ${status} =     Run Keyword And Return Status  Should Not Be Empty   ${myAccountIntID}
    \   Log     ${status}
    \   Exit For Loop If    ${status} == True
    Set test variable  ${myAccountIntID}

    :FOR  ${INDEX}  IN RANGE  44  47
    \   Log     ${INDEX}
    \   ${myCompanyId}=  string get  11  ${INDEX}
    \   ${status} =     Run Keyword And Return Status  Should Not Be Empty   ${myCompanyId}
    \   Log     ${status}
    \   Exit For Loop If    ${status} == True
    Set test variable  ${myCompanyId}
    Log screen

Open CCLS Get Line Amounts
    [Arguments]  ${plasticNumber}
    Send clear
    XCSR
    Log screen
    Fill field by label     FUNCTION    CCLS
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Sleep           1
    Log screen
 #   String found  2  51  NO MORE CRD LINES             #sometimes we have "MORE DATA LINES TO DISPLAY"
    ${myCreditLineAmount}=  string get  12  46
    Set test variable  ${myCreditLineAmount}
    ${myCashLineAmount}=  string get  12  75
    Set test variable  ${myCashLineAmount}
    ${myCreditLineAmount}=  Remove String  ${myCreditLineAmount}  .
    ${myCreditLineAmount}=  Convert To Number  ${myCreditLineAmount}  2
    ${myNew1CreditLineAmount}=  Evaluate  (${myCreditLineAmount})+5
    ${myNew2CreditLineAmount}=  Evaluate  (${myNew1CreditLineAmount})+5
    ${myNew1CreditLineAmount}=  Convert to String  ${myNew1CreditLineAmount}
    ${myNew2CreditLineAmount}=  Convert to String  ${myNew2CreditLineAmount}
    ${myNew1CreditLineAmount}=  Get Substring  ${myNew1CreditLineAmount}  0  -2
    ${myNew2CreditLineAmount}=  Get Substring  ${myNew2CreditLineAmount}  0  -2
    Set test variable  ${myNew1CreditLineAmount}
    Set test variable  ${myNew2CreditLineAmount}
    ${myCashLineAmount}=  Remove String  ${myCashLineAmount}  .
    ${myCashLineAmount}=  Convert To Number  ${myCashLineAmount}  2
    ${myNew1CashLineAmount}=  Evaluate  (${myCashLineAmount})+5
    ${myNew2CashLineAmount}=  Evaluate  (${myNew1CashLineAmount})+5
    ${myNew1CashLineAmount}=  Convert to String  ${myNew1CashLineAmount}
    ${myNew2CashLineAmount}=  Convert to String  ${myNew2CashLineAmount}
    ${myNew1CashLineAmount}=  get Substring  ${myNew1CashLineAmount}  0  -2
    ${myNew2CashLineAmount}=  get Substring  ${myNew2CashLineAmount}  0  -2
    Set test variable  ${myNew1CashLineAmount}
    Set test variable  ${myNew2CashLineAmount}

From CCLS To CCLM Add New Line Amounts
    [Arguments]  ${newCrLAmount}  ${newCashLAmount}  ${date}
    Send pf10
    Log screen
    Fill field by label  CREDIT LINE AMOUNT  ${newCrLAmount}
    Fill field by label  CASH LINE AMOUNT  ${newCashLAmount}
    Fill field by label  LINE START DT  ${date}
    Log screen
    Send pf5
    Log screen
    String found  2  51  ADD SUCCESSFUL
    Send pf10
    Log screen
    Fill field by label  NEXT:  1
    Send enter
    Log screen

On CCLS Select First Cr Cash Line
    [Arguments]  ${plasticNumber}
    Send clear
    XCSR
    Log screen
    Fill field by label     FUNCTION    CCLS
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Sleep           1
    Log screen
    Fill field  13  2  SEL
    Send enter
    Log screen
    String found  2  51  ACTION SUCCESSFUL

On CCLM Change Cr Cash Line
    [Arguments]  ${newCrLAmount}  ${newCashLAmount}
    Fill field by label  CREDIT LINE AMOUNT  ${newCrLAmount}
    Fill field by label  CASH LINE AMOUNT  ${newCashLAmount}
    Log screen
    Send pf4
    Log screen
    String found  2  51  CHANGE SUCCESSFUL

Verify Cr Cash Line on table DCTCL_CRED_LN
    [Arguments]  ${accountIntId}  ${date}  ${CreditLineAmount}  ${CashLineAmount}
    From ISPF go to SQL query
    Send query    SELECT CL_STRT_DT, CL_END_DT, CL_CRD_APV_AM, CL_CASH_AM
          ...     FROM &{environment}[owner].DCTCL_CRED_LN
          ...     WHERE AC_INTRL_ID = '${myAccountIntID}'
          ...           AND CL_ANAL_DT = '${date}'
          ...     ORDER BY TC_UPDT_TS DESC
          ...     WITH UR;
    Sleep           1
    Log screen
    Send enter
    Sleep           1
    Log screen
    String found    3   29  Select Statement Browse

    String found  11  2  ${date}
    String found  11  13  31.12.2799

    :FOR  ${INDEX}  IN RANGE  24  40
    \   Log     ${INDEX}
    \   ${ClCrdApvAm}=  string get  11  ${INDEX}
    \   ${status} =     Run Keyword And Return Status  Should Not Be Empty   ${ClCrdApvAm}
    \   Log     ${status}
    \   Exit For Loop If    ${status} == True
    Set test variable  ${ClCrdApvAm}
    ${ClCrdApvAm}=  Convert To Number  ${ClCrdApvAm}
    Log  ${ClCrdApvAm}
    ${numberNewCreditLineAmount}=  Convert To Number  ${CreditLineAmount}
    Log  ${numberNewCreditLineAmount}
    Should Be Equal  ${ClCrdApvAm}  ${numberNewCreditLineAmount}
    Log screen

    :FOR  ${INDEX}  IN RANGE  42  58
    \   Log     ${INDEX}
    \   ${ClCashAm}=  string get  11  ${INDEX}
    \   ${status} =     Run Keyword And Return Status  Should Not Be Empty   ${ClCashAm}
    \   Log     ${status}
    \   Exit For Loop If    ${status} == True
    Set test variable  ${ClCashAm}
    ${ClCashAm}=  Convert To Number  ${ClCashAm}
    Log  ${ClCashAm}
    ${numberNewCashLineAmount}=  Convert To Number  ${CashLineAmount}
    Log  ${numberNewCashLineAmount}
    Should Be Equal  ${ClCashAm}  ${numberNewCashLineAmount}
    Log screen