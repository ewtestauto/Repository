*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin


*** Variables ***
# Here put new description for test
${transactionDescription}=  TATEST 20200707
# TODO as test variable from EXTENDED CREDIT PARM - PCD 906075
# Don't change variables below:
${PlCoNr}=  3104
${AcOwnr1Cd}=  10220
${plasticFirstNumber}=  4
${transactionCode}=  5935
${transactionReasonCode}=  PU
${transactionCurrencyCode}=  978
${transactionAmount}=  55,00
${creditPlanName}=  DE
${minRepaymentPeriod}=  48

