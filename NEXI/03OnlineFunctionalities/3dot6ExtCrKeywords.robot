*** Settings ***
Documentation  Includes keywords using in Extended credit process defined within _*3dot6ExtCrKeywords.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI\\03OnlineFunctionalities*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    String
Library    DateTime
#Library    builtin

Resource   ../Environments.robot
Resource   3dot6ExtCrVariables.robot

*** Keywords ***
Find plastic for test 3.6 Extended Credit
    [Arguments]     ${plasticFirstNumber}
        [Documentation]  Chooses plastic card for test 3.6 Extended Credit and sets it as a test variable.
    ...
    ...  Usage:
    ...
    ...    - ``Find plastic for test 3.6  Extended Credit  ${plasticFirstNumber}``, where ${plasticFirstNumber} is first number of plastic: 4 for VISA or 5 for MasterCard.
    ...
    ...  An example:
    ...    - ``Find plastic for test 3.6  Extended Credit  4``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `From ISPF go to SQL query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    From ISPF go to SQL query
    Send query      SELECT P.PL_ID
           ...      FROM &{environment}[owner].DCTPL_PLASTIC P,
           ...          &{environment}[owner].DCTAC_ACCOUNT A
           ...      WHERE
           ...          P.AC_INTRL_ID = A.AC_INTRL_ID
           ...          AND A.AC_CRD_TYP_CD = 'C'
           ...          AND P.PL_CUR_STAT_CD = 'AA'
           ...          AND P.PL_CUR_STAT_RSN_CD = 'AA'
           ...          AND P.PL_CUR_EXP_DT > '${PlCurExpDate}'
           ...          AND P.PL_CO_NR = '${PlCoNr}'
           ...          AND A.AC_OWNR1_CD = '${AcOwnr1Cd}'
           ...       WITH UR;
    Sleep           1
    Log screen
    Send enter
    Log screen
    String found    3   29  Select Statement Browse

    ${myPlastic}=   string get  13  2
    Set test variable  ${myPlastic}
    Log screen

Open CAAE Fill Out Extended Credit
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens CAAE screen for plastic card.
    ...  Fills out with data from test variables: ${transactionCode}, ${transactionReasonCode}, ${transactionCurrencyCode}, ${transactionAmount}, ${transactionDescription}.
    ...
    ...  Usage:
    ...
    ...    - ``Open CAAE Fill Out Extended Credit  ${plasticNumber}``, where ${plasticNumber} is plastic number to open in CAAE.
    ...
    ...  An example:
    ...    - ``Open CAAE Fill Out Extended Credit  ${myPlastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    XCSR
    Log screen
    Fill field by label     FUNCTION    CAAE
    Fill field by label     ACCOUNT  ${plasticNumber}
    Send enter
    Log screen
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

Open CAAD Fill Out Extended Credit
    [Arguments]  ${plasticNumber}  ${transactionDescription}
    [Documentation]  Opens CAAD screen for plastic card.
    ...  Finds transactions based on the description ${transactionDescription} from test variables.
    ...  Fills EXTENDED CREDIT PLAN, EXTENDED CREDIT REPAYMENT TERM with values from test variables.
    ...
    ...  Usage:
    ...
    ...    - ``Open CAAD Fill Out Extended Credit  ${plasticNumber}  ${transactionDescription}``,
    ...  where ${plasticNumber} is plastic number to open in CAAD and
    ...  ${transactionDescription} is description of transaction to add to extended credit.
    ...
    ...  An example:
    ...    - ``Open CAAD Fill Out Extended Credit  ${myPlastic}  ${transactionDescription}``
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
    Fill field   16  4  CXEC
    Log screen
    Send enter
    Log screen
    Fill field by label     EXTENDED CREDIT PLAN                  ${creditPlanName}
    Fill field by label     EXTENDED CREDIT REPAYMENT TERM        ${minRepaymentPeriod}
    Send pf5
    Sleep           1
    Log screen
    String found  2  51  ADD SUCCESSFUL
    Sleep           1
    Log screen

