*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime



Resource   ../Environments1.robot
Resource   Setup_vd_Keywords.robot
Resource   ../Set_Teardown.robot

Test Setup     Test setup  ${environment name}
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

${company id}   20000        # company id for SAANA

#constant variables for this test
${PlsMailingMethod} 	BRN
${PinMailingMethod}     BRN
${LanguageCode}	     	FIN

#variables to change
${RequestID}	EQ70006VD2020-07-08_09.10.00.1
#${Hetu}        202001-1A23Hetu

#optional change
#${FirstName}           	NOREGFEBF
#${Surname}             	NOREGFEB
#${DateOfBirth}         	1979-09-09
#${IssuingBranch}	    500094
#${DeliveryBranch}		584150
#${LanguageCode}	     	FIN
${PL_EMB_LN1_NM}	    NOREGVEGENF NOREGVEGENS
${IBAN}		        	FI764645312310222063

 EXPIRY DATE (7,44) = onlinedate + 3 years then EOM
- OPEN DATE (7,70) = online date
- EMB LINE 1 (8,14) = PL_EMB_LN1_NM
- EMB LINE 2 (8, 54) = PL_EMB_LN2_NM
- CARD STOCK (9,13) = PL_CRD_STK_CD
- PROX IND (9,27) = DV_CLESS_IN
- ISSUING BRANCH (9,76) = ISS_BR_NR
- OWNER   BRANCH (10,76) = AC_BR_NR
- LYL NBR (13,11) = LYL_NBR_PRNTD
- TYPE (13,45) = LYL_TYP
- PRNTD IND (13,63) = MEMB_PRNTD_IN
- BRANCH (16,27) = DELVRD_BR_NR
${statuscode}  20
${warningcode}   00   #21,17
${wariningrsn}  000   #22,17

${plastic}
*** Keywords ***

*** Test Cases ***
setupVD
    Log in to TSO
    verify ic158t
    verify ic159t
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
    Go to CICSK updated
    Get environment date     ${company id}
    XCSR
    Open XDVL  ${plastic}
    Check XDVL   ${statuscode}  ${warningcode}
    XCSR
    Check CUPR
    XCSR
    Check CASP
    XCSR
    Check CAPF
    XCSR
    Check CAMN
    XCSR
    Check CAPI
    XCSR
    Check CPPR
    XCSR
    Check CPPM
    XCSR
    Check XPAD
    XCSR
    Check CPRA
    XCSR
    Check CPSL



