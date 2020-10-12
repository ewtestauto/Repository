*** Settings ***

Library    py3270lib    visible=${TRUE}
Library    user_password
Library    builtin

Library     SoapLibrary
Library     OperatingSstem

*** Variables ***


*** Test Cases ***

Example
    Create Soap Client    https://wsdvas:8443/InteractiveGateway/Generic/Gateway
    ${response}    Call SOAP Method With XML    ${CURDIR}/request.xml
    ${text}    Get Data From XML By Tag    ${response}    tag_name
    Log    ${text}
    Save XML To File    ${response}    ${CURDIR}    response_test



*** Keywords ***

