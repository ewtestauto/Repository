*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime
Library     String
Library     calendar
Library     excelLibrary

Resource   ../SharedKeywordsSAN.robot
Resource   ../Environments1.robot
Resource   Setup_Keywords.robot
Resource   ../Set_Teardown.robot

Test Setup     Test setup   ${environment name}
Test Teardown  Test teardown

*** Variables ***
${environment name}   RLSES
&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=

${company id}   20000

${FirstName}        NAMETSTAUTO01${SPACE*7}
${Surname}          SURNAMETSTAUTO01${SPACE*9}
${ProductKey}       473PRISTDBAS
${LoyaltyNBR}       9876543210
${DOB}              19841115
${hetu}             ${date}-13
${TESTNAME}         TESTSTEST13     # NAME IT SO IT HAS 11 CHARS NOREG200721
${requestid}        ID1000120200723COMBOPRI13

${creditPL}   4010432000063581
${debitPL}    4010462000070740
*** Keywords ***



Check CASP
    [Arguments]     ${plastic}
    fill field by label     FUNCTION   casp
    fill field by label     ACCOUNT     ${plasticNumber}
    send enter
    sleep           1

     String found        4    2     ${ac_cd_CR}
 #   String found        5    2     ${pl_id_CR}
     String found        6    47    ${PersonalID}
#    String found        9    52    ${DOB}
#    String found        12   65    ${OnlineDT}
 #   string found        17   21    1.500

check CAPF
    [Arguments]     ${plastic}  ${plasticType}   ${accountType}  ${creditline}

    fill field by label     FUNCTION    CAPF
    fill field by label     ACCOUNT     ${plasticNumber}
    send enter
    sleep           1
    String found  4   26  ${name}
    String found  5   26 ${surname}
    String found    4  64  AA
    String found    5  64   AA
    String found    5   56   ${plasticType}
    String found     4   56  ${accountType}
    String found    13  23    ${creditline}

check camn
    [Arguments]     ${plastic}  ${plasticType}   ${accountType}  ${languagecode}

    fill field by label     FUNCTION    CAPF
    fill field by label     ACCOUNT     ${plasticNumber}
    send enter
    sleep           1
    String found    5  64  AA
    String found    6  64   AA
    String found    6   56   ${plasticType}
    String found     5   56  ${accountType}
    String found  5   26  ${name}
    String found  6   26 ${surname}
    String found  8   41  ${languagecode}
    String found   15  69  ${DELVRD_BR_NR}

*** Test Cases ***
SetupComboPri
  #  Log in to TSO
#    Backup dataset     ICPS.ITST.TAUT.CMBPRI
 #   edit dataset        ICPS.ITST.TAUT.CMBPRI.TEST13
 #   Load table 158T     ICPS.ITST.TAUT.CMBPRI.TEST13
 #   Get out of TSO/CICSK/SAREGKT
 #   Log out of TSO session
  #  Go to CICSK
  #  Run XOBK and retrieve new plastic id     ${requestid}
  #  Get out of TSO/CICSK/SAREGKT
  #  Log in to TSO
  #  find plastic in ic158t
  #  find plastics in ic161t
  #  Get out of TSO/CICSK/SAREGKT
  #  Log out of TSO session
  #  Go to CICSK
  #  Get environment date     ${company id}
  #  XCSR
  #   Check XDVL    ${creditPL}     30  CF1  VCA
  #   xcsr
  #   Verify XDVD  ${creditPL}    ${newExpDtCRE}   30  CF1  VCA
  #   xcsr
  #   Check XDVL     ${debitPL}    30  DC1  BA1
  #   xcsr
  #   Verify XDVD  ${debitPL}  ${newExpDtCRE}   30  DC1  BA1
  #  xcsr
  #   Check CUPR  ${debitPL}   ${date}-01
  #   xcsr
  #   Check CASP
      xcsr
      Check CapF  ${creditPL}  ${creditline}
      xcsr
      check capf   ${debitPL}   ${creditline}






