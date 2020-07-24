*** Settings ***
Documentation  Includes keywords using in Lost or Stolen Credit Card process defined within _*3dot1LostStolen.robot*_ file.
...
...  Path to the file: _*\\PyCharm\\NEXI\\03OnlineFunctionalities*_
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    String
Library    DateTime
#Library    builtin

Resource   ../Environments.robot
Resource   3dot1LostStolenCardVariables.robot

*** Keywords ***
Find plastic for test 3.1 Lost Stolen Card
    [Arguments]  ${date}
    [Documentation]  Chooses plastic card for test 3.1 Lost Stolen Card with given expiration date in format dd.mm.yyyy
    ...  and sets number of plastic as a test variable ${myPlastic} and Company Id number for choosen plastic
    ...  as a test variable ${myCompanyId}.
    ...
    ...  Usage:
    ...
    ...    - ``Find plastic for test 3.1 Lost Stolen Card  ${date}``, where ${date} is date in format dd.mm.yyyy.
    ...
    ...  An example:
    ...    - ``Find plastic for test 3.1 Lost Stolen Card  01.12.2021``
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
          ...     AND B.PL_CUR_STAT_CD = 'AA'
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

    :FOR  ${INDEX}  IN RANGE  44  47
    \   Log     ${INDEX}
    \   ${myCompanyId}=  string get  11  ${INDEX}
    \   ${status} =     Run Keyword And Return Status  Should Not Be Empty   ${myCompanyId}
    \   Log     ${status}
    \   Exit For Loop If    ${status} == True
    Set test variable  ${myCompanyId}
    Log screen

Open CLSI
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens CLSI screen for given plastic card number.
    ...
    ...  Usage:
    ...
    ...    - ``Open CLSI  ${plasticNumber}``, where ${plasticNumber} is card number.
    ...
    ...  An example:
    ...    - ``Open CLSI  ${myPlastic}``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Send clear
    XCSR
    Fill field by label     FUNCTION    CLSI
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Sleep           1
    Log screen
    String found  2  51  ENTER INCIDENT INFORMATION
    Log screen

Fill out CLSI
    [Arguments]  ${lossCode}
    [Documentation]  Fills CLSI screen with ID SOURCE=CHPH, CIRCUMSTANCE=UK and given LOSS CODE ${lossCode},
    ...  0 for lost and 1 for stolen.
    ...
    ...  Usage:
    ...
    ...    - ``Fill Out CLSI  ${lossCode}``, where ${lossCode} is loss code: 0 for lost and 1 for stolen.
    ...
    ...  An example:
    ...    - ``Fill Out CLSI  0``
    ...
    ...  | Pre-requisite  | |
    ...  | Co-requisite   | `Open CLSI` |
    ...  | | `Get environment date`, available in *\\PyCharm\\NEXI\\01a.plastic_setup\\PlasticSetupKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Fill field by label  ID SOURC  CHPH
    Fill field by label  LOSS CODE  ${lossCode}
    Fill field by label  CIRCUMSTANCE  UK
    Send pf5
    Log screen
    String found  2  51  INFO CAPTURED, PF2 TO CONTINUE
    Send pf2
    Log screen
    String found  2  51  INQUIRY SUCCESSFUL
    Fill field by label  LOSS DATE/TIME  ${online_date}
    Log screen
    Send pf6
    Log screen
    String found  2  51  INQUIRY SUCCESSFUL
    Send pf4
    Log screen
    String found  2  51  INFO CAPTURED, PF2 TO CONTINUE
    Send pf2
  # TODO  String found - we can have at least two kinds of strings: when the plastic has transaction or has not
  # String found  2  51  INQUIRY SUCCESSFUL
  # or NO TXN DATA FOR L/S PLASTIC,
  # when we have card without transaction but we can still make Lost or Stolen Credit Card process
  # and on CAST is presented: Plastic status: LOP; Reason code: LL
    Log screen
    String found  8  13  ${lossCode}
    String found  8  21  &{PCD906221}[loss code desc]
    Send pf10
    Log screen
    String found  2  51  INQUIRY SUCCESSFUL
    Log screen

Open CAPI
    [Arguments]  ${plasticNumber}
    [Documentation]  Opens CAPI screen for given plastic card number.
    ...
    ...  Usage:
    ...
    ...    - ``Open CAPI  ${plasticNumber}``, where ${plasticNumber} is card number.
    ...
    ...  An example:
    ...    - ``Open CAPI  ${myPlastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Send clear
    XCSR
    Fill field by label     FUNCTION    CAPI
    Fill field by label     ACCOUNT     ${plasticNumber}
    Send enter
    Sleep           1
    Log screen
    String found  2  51  INQUIRY SUCCESSFUL
    ${my1Plastic}=  string get  5  2            #Takes plastic number for ${myPlastic} in format xxxx-xxxx-xxxx-xxxx
                                                #to use it e.g. in searching on CAST screen and stets as ${my1Plastic}
    Set test variable  ${my1Plastic}
    Log  ${my1Plastic}

Verify plastic status on CAST
    [Arguments]  ${plasticNumber}
    [Documentation]  Checks status of plastic card on CAST screen for given plastic card number.
    ...  It should be equal status from PCD906221 for NEW STATUS and REASON CODE,
    ...  according to  ${lossCode} choosen in test variable.
    ...
    ...  Usage:
    ...
    ...    - ``Verify plastic status on CAST  ${plasticNumber}``, where ${plasticNumber} is card number.
    ...
    ...  An example:
    ...    - ``Verify plastic status on CAST  ${myPlastic}``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Get data from PCD906221` |
    ...  | Co-requisite   | `XCSR`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    Send clear
    XCSR
    Fill field by label  FUNCTION  CAST
    Fill field by label  ACCOUNT  ${plasticNumber}
    Send enter
    Sleep  1
    Log screen

    :FOR  ${INDEX}  IN RANGE  1  50
    \   Log     ${INDEX}
    \   ${INDEX_STRING}=     Convert To String   ${INDEX}
    \   Fill field by label     NEXT     ${INDEX_STRING}
    \   Send enter
    \   Log screen
    \   ${status} =     Run Keyword And Return Status  string found    12  11  ${plasticNumber}
    \   Log     ${status}
    \   Log screen
    \   Exit For Loop If    ${status} == True

    Log screen
    String found  12  53  &{PCD906221}[new status] &{PCD906221}[reason cd]
    Log screen

Verify plastic status on table
    [Arguments]  ${plasticNumber}
    [Documentation]  Checks status of plastic card on DCTPL_PLASTIC table for given plastic card number.
    ...  It should be equal status from PCD906221 for NEW STATUS and REASON CODE,
    ...  according to  ${lossCode} choosen in test variable.
    ...
    ...  Usage:
    ...
    ...    - ``Verify plastic status on table  ${plasticNumber}``, where ${plasticNumber} is card number.
    ...
    ...  An example:
    ...    - ``Verify plastic status on table  ${myPlastic}``
    ...
    ...  | Pre-requisite  | `Log in to TSO`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Get data from PCD906221` |
    ...  | Co-requisite   | `From ISPF go to SQL query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Send query`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | Post-requisite | |
    ...
    From ISPF go to SQL query
    Send query    SELECT PL_ID, PL_CUR_STAT_CD, PL_CUR_STAT_RSN_CD
          ...     FROM &{environment}[owner].DCTPL_PLASTIC
          ...     WHERE PL_ID = '${plasticNumber}'
          ...     WITH UR;
    Sleep           1
    Log screen
    Send enter
    Sleep           1
    Log screen
    String found    3   29  Select Statement Browse
    String found    11  26    &{PCD906221}[new status]
    String found    11  41    &{PCD906221}[reason cd]
    Sleep           1

Get data from PCD906221
# First should be used "Find plastic for test 3.1 Lost Stolen Card" to find Company ID
    [Documentation]  Gets data from PCD906221 and stores in dictionary ${PCD906221} to verify after Lost or Stolen Credit Card process.
    ...  Requires using "Find plastic for test 3.1 Lost Stolen Card" to find Company ID.
    ...
    ...  Usage:
    ...
    ...  - ``Get data from PCDPCD906221``
    ...
    ...  | Pre-requisite  | `Go to CICSK`, available in *\\PyCharm\\NEXI\\SharedKeywords.robot* file |
    ...  | | `Find plastic for test 3.1 Lost Stolen Card` |
    ...  | Co-requisite   | |
    ...  | Post-requisite | |
    ...
    Send clear
    Send string  u
    Send enter
    Log screen
    Fill field by label  Select Option ===>  2
    Send enter
    Log screen
    Fill field by label  Select Option ===>  1
    Send enter
    Log screen
    Fill field by label  Format ==>          906221
    Send enter
    Log screen
    Run keyword if  '${myCompanyId}'=='33155'  Fill field by label  CG  CSI${SPACE}
    Run keyword if  '${myCompanyId}'=='33155'  Send enter
    Run keyword if  '${myCompanyId}'!='33155'  Fill field by label  CG  DBIT
    Run keyword if  '${myCompanyId}'!='33155'  Send enter
    fill field by label  KEY...  *,*,*,*;*,*,${lossCode}
    Sleep  1
    Log screen
    send pf6
    log screen
    #sleep  1
    string found  1  51  Action Successful
    ${lossCodeDesc}=   string get  8  18
    ${newStatus}=      string get  9  13
    ${reasonCode}=     string get  9  35
    ${frdStatus}=      string get  10  13
    ${frdReasonCode}=  string get  10  35
    Set to dictionary  ${pcd906221}  loss code desc=${lossCodeDesc}
    Set to dictionary  ${pcd906221}  new status=${newStatus}
    Set to dictionary  ${pcd906221}  reason cd=${reasonCode}
    Set to dictionary  ${pcd906221}  frd status=${frdStatus}
    Set to dictionary  ${pcd906221}  frd reason cd=${frdReasonCode}