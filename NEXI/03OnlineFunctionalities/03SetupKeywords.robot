*** Settings ***
Library   Collections        #necessary for using dictionaries
Library   String             #used to format date
#Library   csvSaveAndRetrievePlastic.py

Resource  ../SharedKeywords.robot

*** Keywords ***

Test setup for 03 Setup
    [Arguments]  ${environment_name}
    Set environment2  ${environment name}
    Connect to mainframe
    Log out of TSO session
    Log out of CICSK session
    Set UDFL

Test teardown for 03 Setup
    Get out of TSO/CICSK/SAREGKT
    Log out of TSO session
    Log out of CICSK session
    Log out of mainframe
