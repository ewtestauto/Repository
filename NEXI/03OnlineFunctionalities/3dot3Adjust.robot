*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin

Resource   ../SharedKeywords.robot
Resource   ../01a.plastic_setup/PlasticSetupKeywords.robot      #Here is Keyword Get environment date - maybe we can put it in SharedKeywords
Resource   ../Environments.robot
Resource   03SetupKeywords.robot
Resource   3dot3AdjustKeywords.robot
Resource   3dot3AdjustVariables.robot

Test Setup     Test setup for 03 Setup  ${environment_name}
Test Teardown  Test teardown for 03 Setup

*** Variables ***
${environment_name}  RLSEI
# this is the default environment,  if you want to run in a different environment, run the script like this:
# robot -v environment_name:SITITA04 3dot1LostStolenCard.robot
# or
# robot --variable environment_name:SITITA04 3dot1LostStolenCard.robot

# this has to be here, or the environment won't be set
&{environment}  owner=
...             appprefix=
...             jobprefix=
...             datasetprefix=
...             cicsk=
...             companynumber=
...             pool=
...             examplecompanyid=

*** Test Cases ***
3dot3 Adjustment
# 1. Go to CICKS and check ON_LINE date. Set test variable for expiration date ${plCurExpDate} (ON_LINE date plus 30 days)
#    Set test variable for transaction date ${transactionDate} (ON_LINE date minus 1 day)
    Set plastic expiration date  30
    Set transaction date  1

# 2. Go to TSO and find plastic. Get out of TSO. Log out of TSO.
    Log in to TSO
    Find plastic for test 3.3 Adjustment  ${plCurExpDate}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session

# 3. Go to CICSK with your plastic, open and fill out CAAE screen to execute Adjustment process. Enter these fields:
#       transaction date (online date minus one day)
#       Transaction code 5935
#       Transaction Description (as desired)
#       TRANSACTION REASON CODE >> PU (purchase)
#       TANSACTION CURRENCY CODE >> 978,
#       TRANSACTION AMOUNT >> an amount as desired (e.g. 20,00)
    Go to CICSK
    Open CAAE Fill Out Adjustment  ${myPlastic}

# 4. Go to CAAD screen and find your transaction by description
    Open CAAD Find Transaction  ${myPlastic}  ${transactionDescription}
    Get out of TSO/CICSK/SAREGKT
    Log out of CICSK session

# 5. Check on table DCTJO_POST_ACTION
    Log in to TSO
    Verify transaction on table DCTJO_POST_ACTION  ${myAccountIntID}  ${transactionAmount}  ${transactionDescription}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session