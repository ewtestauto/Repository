*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin

Resource   ../SharedKeywordsSAN.robot
Resource   ../Environments1.robot
Resource   Manual_Rei_Keywords.robot
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


${plastic_from_file}        # plastic used in prebatch and midbatch, retrieved from file reissue/plastic.txt
${account_id_from_file}     # AC_INTRL_ID saved in file in prebatch,  retrieved from file reissue/plastic.txt, used in JSON search after batches
${jsonfile}   IFO04.JSON    # in case the file is already overwritten, check the backup file IFO04.json.DYYMMDD.ttttt

${company id}  20000   # company id for saana
${test case name}   Manual Reissue REG            # required to retrieve proper plastic from plastic.txt

*** Keywords ***


*** Test Cases ***
Postbatch
    Go to CICSK updated
    Get environment date     ${company id}

    get plastic data for manual reissue test  ${test case name}  ${environment name}
    log                                  ${plastic_from_file}
    log                                  ${account_id_from_file}

    Get out of TSO/CICSK/SAREGKT
    Log in to TSO
  #  clean after fake PPRFL.X91EVFBI
    from ISPF search for plastic in file   ${plastic_from_file}   ODSO1.X91ODSRO.ALLBUT50
    from ISPF search for reissued credit plastic in JSON file    ${account_id_from_file}  ${jsonfile}
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
    Go to CICSK updated
    Open XDVL  ${plastic_from_file}
    Check XDVL card status   50

