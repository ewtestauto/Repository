*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin

Resource   ../SharedKeywords.robot
Resource   ../01a.plastic_setup/PlasticSetupKeywords.robot      #Here is Keyword Get environment date - maybe we can put it in SharedKeywords
Resource   ../Environments.robot
Resource   03SetupKeywords.robot
#Resource   3dot2CusMaintenanceKeywords.robot
#Resource   3dot2CusMaintenanceVariables.robot

Test Setup     Test setup for 03 Setup  ${environment_name}
Test Teardown  Test teardown for 03 Setup

*** Variables ***
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

*** Test Cases ***
Test
    Log in to TSO
    Find plastic for test


*** Keywords ***
Find plastic for test
    Send string     r
    Send enter
    Send string     8
    Send enter
    Send string     4
    Send enter
    Send string     3
    Send enter
    String found    3   25  Enter, Execute and Explain SQL
    Send query    SELECT B.PL_ID, A.AC_INTRL_ID, AC_CD, A.AC_CO_NR
          ...     FROM &{environment}[owner].DCTAC_ACCOUNT A,
          ...     &{environment}[owner].DCTPL_PLASTIC B
          ...     WHERE A.AC_INTRL_ID = B.AC_INTRL_ID
          ...     AND A.AC_CRD_TYP_CD = 'C'
          ...     AND B.PL_CUR_STAT_CD = 'AA'
          ...     AND B.PL_CUR_STAT_RSN_CD = 'AA'
          ...     AND B.PL_CUR_EXP_DT > '01.05.2022'
          ...     AND B.PL_ID = '4935470031097626'
          ...     WITH UR;
    Sleep  1
    Send enter
    String found    3   29  Select Statement Browse
    ${myPlastic}=  string get  11  2
    Set test variable  ${myPlastic}
    ${myCompanyId}=  string get  11  68
    Set test variable  ${myCompanyId}
    ${myAccountId}=  string get  11  41
    Set test variable  ${myAccountId}
    Log screen
