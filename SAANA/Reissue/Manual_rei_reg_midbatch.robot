*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin
Library    DateTime


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



${statusCode}                      #  current expected status of a card, after first batch it is usually status 30
${alternative_id_from_file}        # alternative number of plastic_from_file, retrieved from reissue/plastic.txt, used for search in PPR1O.X91XEVRO.DAILY
${plastic_from_file}               # plastic used in prebatch, retrieved from reissue/plastic.txt
${account_id_from_file}            # AC_INTRL_ID set in Find Plastic for reissue test, retrieved from reissue/plastic.txt, used in JSON search

${company id}   20000              # companyid for SAANA
${jsonfile}   IFO04.JSON           # in case the file is already overwritten, check the backup file IFO04.json.DYYMMDD.ttttt
${test case name}   Manual Reissue REG            # required to retrieve proper plastic from plastic.txt


*** Keywords ***


*** Test Cases ***
Midbatch
    Go to CICSK updated
    Get environment date     ${company id}

    get plastic data for manual reissue test  ${test case name}    ${environment name}
    log                                  ${plastic_from_file}
    log                                  ${alternative_id_from_file}
    log                                  ${account_id_from_file}

    XCSR
    Open XDVL  ${plastic_from_file}
    Check XDVL card status   30

    Get out of TSO/CICSK/SAREGKT
    Log in to TSO
#   from ISPF  backup dataset  &{environment}[datasetprefix]PPR1O.X91XEVRO.DAILY
    from ISPF search for plastic in file   ${alternative_id_from_file}   PPR1O.X91XEVRO.DAILY
    from ISPF search for plastic in file   ${plastic_from_file}  ODSO1.X91ODSRO.ALLBUT50
#   from ISPF  backup dataset  &{environment}[datasetprefix]IFO04.JSON
    from ISPF search for reissued credit plastic in JSON file  ${account_id_from_file}    ${jsonfile}

 #   Run Keyword if    '${environment name}' == 'CK0A'     from ISPF search for plastic in file   ${alternative_id_from_file}   PPRFL.X91EVFBI
 #   ...    ELSE
 #   ...    fake PPRFL.X91EVFBI   ${alternative_id_from_file}



