*** Settings ***
Documentation  Includes keywords using in Adjustment process defined within _*3dot3Adjust.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI\\03OnlineFunctionalities*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    String
Library    DateTime
#Library    builtin

Resource   ../Environments.robot
Resource   3dot3AdjustVariables.robot

*** Keywords ***
Find plastic for test 3.3 Adjustment
    [Arguments]  ${date}
    [Documentation]  Chooses plastic card for test 3.3 Adjustment with given expiration date in format dd.mm.yyyy
    ...  and sets number of plastic as a test variable ${myPlastic}, account internal ID as a test variable
    ...  ${myAccountIntID} and Company Id number for choosen plastic as a test variable ${myCompanyId}.
    ...
    ...  Usage:
    ...
    ...    - ``Find plastic for test 3.3 Adjustment  ${date}``, where ${date} is date in format dd.mm.yyyy.
    ...
    ...  An example:
    ...    - ``Find plastic for test 3.3 Adjustment  01.12.2021``
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

Set transaction date
    [Arguments]  ${noOfDays}
    [Documentation]  Sets transaction date as a test variable ${transactionDate} in format dd.mm.yyyy.
    ...  To do this takes online date and subtracts given number of days ${noOfDays}.
    ...
    ...  Usage:
    ...
    ...    - ``Set transaction date  ${noOfDays}``, where ${noOfDays} is number of days that should be subtract from online date.
    ...
    ...  An example:
    ...    - ``Set transaction date 1``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Get environment date`, available in *\\PyCharm\\NEXI\\01a.plastic_setup\\PlasticSetupKeywords.robot* file |
    ...  | | `Past date`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Get out of TSO/CICSK/SAREGKT`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Go to CICSK
    Send clear
    XCSR
    Get environment date  &{environment}[examplecompanyid]
    Log screen
    ${transactionDate}=  Past date  ${online_date}  ${noOfDays}
    Set test variable  ${transactionDate}
    Log  ${transactionDate}
    Get out of TSO/CICSK/SAREGKT

Open CAAE Fill Out Adjustment
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens CAAE screen for given plastic card number.
    ...  Fills out with data from test variables: ${transactionCode}, ${transactionReasonCode}, ${transactionCurrencyCode},
    ...  ${transactionAmount}, ${transactionDescription}.
    ...
    ...  Usage:
    ...
    ...    - ``Open CAAE Fill Out Adjustment  ${plasticNumber}``, where ${plasticNumber} is card number.
    ...
    ...  An example:
    ...    - ``Open CAAE Fill Out Adjustment  ${myPlastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Send clear
    XCSR
    Log screen
    Fill field by label     FUNCTION    CAAE
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Sleep           1
    Log screen
    String found  2  51  Action Successful
    Fill field by label     TRANSACTION DATE  ${transactionDate}
    Fill field by label     TRANSACTION CODE  ${transactionCode}
    Fill field by label     TRANSACTION DESCRIPTION  ${transactionDescription}
    Fill field by label     TRANSACTION REASON CODE  ${transactionReasonCode}
    Fill field by label     TANSACTION CURRENCY CODE  ${transactionCurrencyCode}
    Fill field by label     TRANSACTION AMOUNT  ${transactionAmount}
    Log screen
    Send pf5
    Log screen
    Sleep           1
    String found   2   51  Action Successful
    Sleep  1
    Log screen

Open CAAD Find Transaction
    [Arguments]  ${plasticNumber}  ${transactionDescription}
    [Documentation]  Opens CAAD screen for plastic card.
    ...  Finds transactions based on the description ${transactionDescription} from test variables.
    ...
    ...  Usage:
    ...
    ...    - ``Open CAAD Find Transaction  ${plasticNumber}  ${transactionDescription}``,
    ...  where ${plasticNumber} is plastic number to open in CAAD and
    ...  ${transactionDescription} is description of transaction to add to extended credit.
    ...
    ...  An example:
    ...    - ``Open CAAD Find Transaction  ${myPlastic}  ${transactionDescription}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    XCSR
    Fill field by label     FUNCTION    CAAD
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Log screen
    :FOR  ${INDEX}  IN RANGE  1  50
    \   Log     ${INDEX}
    \   ${INDEX_STRING}=     Convert To String   ${INDEX}
    \   Fill field by label     NEXT     ${INDEX_STRING}
    \   Send enter
    \   Log screen
    \   ${status} =     Run Keyword And Return Status  string found    17  40  ${transactionDescription}
    \   Log     ${status}
    \   Log screen
    \   Exit For Loop If    ${status} == True
    Log screen

Verify transaction on table DCTJO_POST_ACTION
    [Arguments]  ${accountIntID}  ${trAmount}  ${trDescription}
    [Documentation]  Checks transaction on DCTPL_PLASTIC table for given Account Interal Id, Transaction Amount, Transaction Description.
    ...
    ...  Usage:
    ...
    ...    - ``Verify transaction on table DCTJO_POST_ACTION  ${accountIntID}  ${trAmount}  ${trDescription}``,
    ...    where ${accountIntID} is Account Internal ID, ${trAmount} is Transaction Amount and
    ...    ${trDescription} is Transaction Description.
    ...
    ...  An example:
    ...    - ``Verify transaction on table DCTJO_POST_ACTION  ${myAccountIntID}  ${transactionAmount}  ${transactionDescription}``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `From ISPF go to SQL query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    From ISPF go to SQL query
    Send query    SELECT JO_PSTD_AM, TR_DT, JO_TXN_DESC_TX
          ...     FROM &{environment}[owner].DCTJO_POST_ACTION
          ...     WHERE AC_INTRL_ID = ${accountIntID}
          ...     AND JO_PSTD_AM = ${trAmount}
          ...     AND JO_TXN_DESC_TX = '${trDescription}'
          ...     WITH UR;
    Sleep  1
    Log screen
    Send enter
    Sleep           1
    Log screen
    String found    3   29  Select Statement Browse
    String found    11  14    ${transactionAmount}
    String found    11  20   ${transactionDate}
    String found    11  31   ${transactionDescription}