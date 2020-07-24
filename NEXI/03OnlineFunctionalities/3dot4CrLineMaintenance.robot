*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin

Resource   ../SharedKeywords.robot
Resource   ../01a.plastic_setup/PlasticSetupKeywords.robot      #Here is Keyword Get environment date - maybe we can put it in SharedKeywords
Resource   ../Environments.robot
Resource   03SetupKeywords.robot
Resource   3dot4CrLineMaintenanceKeywords.robot
Resource   3dot4CrLineMaintenanceVariables.robot

Test Setup     Test setup for 03 Setup  ${environment_name}
Test Teardown  Test teardown for 03 Setup

*** Variables ***
${environment_name}  RLSEI
# this is the default environment,  if you want to run in a different environment, run the script like this:
# robot -v environment_name:SITITA04 3dot4CrLineMaintenance.robot
# or
# robot --variable environment_name:SITITA04 3dot4CrLineMaintenance.robot

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
3dot4 Cr Line Maintenance
# 1. Go to CICKS and check ON_LINE date. Set test variable for expiration date ${plCurExpDate} (ON_LINE date plus 30 days).
    Set plastic expiration date  30

# 2. Go to TSO and find plastic. Get out of TSO. Log out of TSO.
    Log in to TSO
    Find plastic for test 3.4 Cr Line Maintenance  ${plCurExpDate}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session

# 3. Go to CICKS, open CCLS screen for plastic from previous step, take Credit Line Amount and Cash Line Amount and set
#    as test variables: ${myCreditLineAmount}, ${myCashLineAmount}. Add to them 5, calculate new Credit and Cash
#    Line Amounts and set as test variables: ${myNew1CreditLineAmount}, ${myNew1CashLineAmount}.
#    Add 5 to ${myNew1CreditLineAmount}, ${myNew1CashLineAmount}, calculate new Credit and Cash Line Amounts
#    and set as test variables: ${myNew2CreditLineAmount}, ${myNew2CashLineAmount}.
    Go to CICSK
    Open CCLS Get Line Amounts  ${myPlastic}

# 4. Go to CCLM screen and add new Credit and Cash Line Amounts (${myNew1CreditLineAmount}, ${myNew1CashLineAmount})
#    for date equal online date. Use PF5 for adding.
    From CCLS To CCLM Add New Line Amounts  ${myNew1CreditLineAmount}  ${myNew1CashLineAmount}  ${online_date}
    Get out of TSO/CICSK/SAREGKT
    Log out of CICSK session

#5. Verify on table DCTCL_CRED_LN
    Log in to TSO
    Verify Cr Cash Line on table DCTCL_CRED_LN  ${myAccountIntID}  ${online_date}  ${myNew1CreditLineAmount}  ${myNew1CashLineAmount}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session

#6.  Go to CCLM screen. Select line with Credit and Cash Line Amounts added in previous step (it should be first line
#    on the list).
    Go to CICSK
    On CCLS Select First Cr Cash Line  ${myPlastic}

#7. On CCLS screen change Credit and Cash Line Amounts (${myNew2CreditLineAmount}, ${myNew2CashLineAmount}).
#   Use PF4 for changing.
    On CCLM Change Cr Cash Line  ${myNew2CreditLineAmount}  ${myNew2CashLineAmount}
    Get out of TSO/CICSK/SAREGKT
    Log out of CICSK session

#8. Verify on table DCTCL_CRED_LN
    Log in to TSO
    Verify Cr Cash Line on table DCTCL_CRED_LN  ${myAccountIntID}  ${online_date}  ${myNew2CreditLineAmount}  ${myNew2CashLineAmount}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session