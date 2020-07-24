*** Settings ***
Library   Collections        #necessary for using dictionaries
Library   String             #used to format date
#Library   csvSaveAndRetrievePlastic.py

Resource  SharedKeywordsSAN.robot

*** Keywords ***

Test setup
    [Arguments]  ${environment name}
    Set environment2  ${environment name}
    Connect to mainframe
    Log out of TSO session
    Log out of CICSK session
    Set UDFL

Test teardown
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
    Log out of CICSK session
    Log out of mainframe

