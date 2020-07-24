*** Settings ***
Library    py3270lib    visible=${TRUE}
Library    user_password
#Library    builtin


*** Variables ***
${lossCode}=  0                 # choose the right ${lossCode}, where loss code: 0 for lost and 1 for stolen.
