*** Settings ***
Documentation    Suite description
Resource         Manual_Rei_Keywords.robot

*** Variables ***
#set by 'get plastic for manual reissue' test keyword
${plastic_from_file}=

*** Test Cases ***
Test title
    get plastic data for manual reissue test  Manual Reissue REG  ${EMPTY}
    log  ${plastic_from_file}
    log  ${online_date_from_file}
    log  ${alternative_id_from_file}
    log  ${account_number_from_file}

*** Keywords ***
