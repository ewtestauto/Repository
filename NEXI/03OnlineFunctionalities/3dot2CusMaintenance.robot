*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin

Resource   ../SharedKeywords.robot
Resource   ../01a.plastic_setup/PlasticSetupKeywords.robot      #Here is Keyword Get environment date - maybe we can put it in SharedKeywords
Resource   ../Environments.robot
Resource   03SetupKeywords.robot
Resource   3dot2CusMaintenanceKeywords.robot
Resource   3dot1LostStolenCardKeywords.robot
Resource   3dot2CusMaintenanceVariables.robot


Test Setup     Test setup for 03 Setup  ${environment_name}
Test Teardown  Test teardown for 03 Setup

*** Variables ***
# Before run this test case put new adrress as variables in 3dot2CusMaintenanceVariables.robot file

${environment_name}  RLSEI
# this is the default environment,  if you want to run in a different environment, run the script like this:
# robot  -v environment_name:SITITA04 3dot2CusMaintenance.robot
# or
# robot  --variable environment_name:SITITA04 3dot2CusMaintenance.robot

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
3.2 Cus Maintenance
# 1. Go to CICKS and check ON_LINE date. Set test variable for expiration date ${plCurExpDate} (ON_LINE date plus 30 days)
    Set plastic expiration date  30

# 2. Go to TSO and find plastic. Take plastic number and take company number. Get out of TSO. Log out of TSO.
    Log in to TSO
    Find plastic for test 3.2 Cus Maintenance  4
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session

# 3. Go to CICKS, open STAD screen for plastic from previous step, take an account number and change some of fields (ZIP, CITY, PROV and COUNTRY).
    Go to CICSK
    Open STAD  ${myPlastic}
    New Address

# 4. Open again STAD screen and make sure that fields are changed
    Send clear
    XCSR
    Open STAD  ${myPlastic}
    Check New Adrress

#   These four lines are not used - company number is checked in SQL query
#    Open CAPN screen for the account number and take company number
#    Send clear
 #   XCSR
#    Check Co on CAPN  ${myAccount}

# 5. Check environment date for company number from previous screen. Log out of CICSK.
    Send clear
    XCSR
    Get environment date  ${myCompanyId}
    Get out of TSO/CICSK/SAREGKT

# 6. Log in to TSO. On table ADDR_X_ACCT_TB (for our account and ADDR_EFF_DATE which is equal online date):
#    check ADDR_EXP_DATE= '31.12.2799', save ADDR_STREET_ID and ADDR_BLDG_NBR_HASH.
    Log in to TSO
    Check on table ADDR_X_ACCT_TB  ${myAccount}  ${online_date}

# 7. On table ADDRESS_TB (for ADDR_STREET_ID, ADDR_BLDG_NBR_HASH and LST_MAINT_DATE= real date of changes): check ADDR_LINE_1, CITY_NAME, STATE_NAME_OR_CD, CNTRY_CD_5.
#   They should be equal new address.
    Check on table ADDRESS_TB  ${myAddrStreetId}  ${myAddrBldgNbrHash}
