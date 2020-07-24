*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password

Resource   ../SharedKeywords.robot
Resource   ../Environments.robot
Resource   ../01a.plastic_setup/PlasticSetupKeywords.robot
Resource   03SetupKeywords.robot
Resource   3dot1LostStolenCardKeywords.robot
Resource   3dot6ExtCrKeywords.robot

Test Setup     Test setup for 03 Setup  ${environment_name}
Test Teardown  Test teardown for 03 Setup

*** Variables ***
# Before run this test case put new description as variable in 3dot6ExtCrVariables.robot file

${environment_name}  RLSEI
# this is the default environment,  if you want to run in a different environment, run the script like this:
# robot -v environment_name:SITITA04 3dot6ExtCr.robot
# or
# robot --variable environment_name:SITITA04 3dot6ExtCr.robot

# this has to be here, or the environment won't be set
&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=
...             examplecompanyid=

*** Keywords ***

*** Test Cases ***
3.6 Extended Credit
# 1. Go to CICKS and check ON_LINE date. Set test variable for expiration date ${plCurExpDate} (ON_LINE date plus 30 days)
    Set plastic expiration date  30

# 2. Go to TSO and find plastic (where PL_CO_NR=03104 and AC_OWNR_1_CD=10220). Get out of TSO. Log out of TSO.
    Log in to TSO
    Find plastic for test 3.6 Extended Credit  ${plasticFirstNumber}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session

# 3. Go to CICKS, open CAAE screen for plastic from previous step, enter these fields:
#       Transaction code 5935
#       Transaction Description (as desired)
#       TRANSACTION REASON CODE >> PU (purchase)
#       TANSACTION CURRENCY CODE >> 978,
#       TRANSACTION AMOUNT >> an amount greater than the minimum limit (e.g. 55,00)
    Go to CICSK
    Open CAAE Fill Out Extended Credit  ${myPlastic}

# 4. Go to CAAD screen for the plastic, find your transaction from previous step (date, amount, description).
#    Input command next to the transaction: CXEC. Fill these fields with parameters from PCD:
#    EXTENDED CREDIT PLAN: DE
#    EXTENDED CREDIT REPAYMENT TERM: a number between min. and max. repayment period (e.g. 48)
    Open CAAD Fill Out Extended Credit  ${myPlastic}  ${transactionDescription}
