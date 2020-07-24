*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin

Resource   ../SharedKeywords.robot
Resource   ../01a.plastic_setup/PlasticSetupKeywords.robot      #Here is Keyword Get environment date - maybe we can put it in SharedKeywords
Resource   ../Environments.robot
Resource   03SetupKeywords.robot
Resource   3dot1LostStolenCardKeywords.robot
Resource   3dot1LostStolenCardVariables.robot

Test Setup     Test setup for 03 Setup  ${environment_name}
Test Teardown  Test teardown for 03 Setup

*** Variables ***
# Before run  this test case choose the right variable in 3dot1LostStolenCardVariables.robot file

${environment_name}  RLSEI
# this is the default environment, if you want to run in a different environment, run the script like this:
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

&{PCD906221}    loss code desc=
...             new status=
...             reason cd=
...             frd status=
...             frd reason cd=
#set by keyword, stores data read from this pcd

*** Keywords ***

*** Test Cases ***
3dot1 Lost Stolen Card
# 1. Go to CICKS and check ON_LINE date. Set test variable for expiration date ${plCurExpDate} (ON_LINE date plus 30 days)
    Set plastic expiration date  30

# 2. Go to TSO and find plastic. Get out of TSO. Log out of TSO.
    Log in to TSO
    Find plastic for test 3.1 Lost Stolen Card  ${plCurExpDate}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session

# 3. Go to CICKS and get data from PCD9060221
    Go to CICSK
    Send clear
    Get data from PCD906221

# 4. Go to CICSK with your plastic, open and fill out CLSI screen to execute Lost/Stolen process
    Open CLSI  ${myPlastic}
    Fill out CLSI  ${lossCode}

# 5. On CAST screen verify status of your plastic. First find on CAPI screen your plastic number in format xxxx-xxxx-xxxx-xxxx.
    Open CAPI  ${myPlastic}
    Verify plastic status on CAST  ${my1Plastic}
    Get out of TSO/CICSK/SAREGKT
    Log out of CICSK session

# 6. Check on table
    Log in to TSO
    Verify plastic status on table  ${myPlastic}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
