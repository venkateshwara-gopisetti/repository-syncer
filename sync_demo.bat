:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
::SET OPERATION MODES::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set operation_modes=cleanup demo

::CHECK IF NO PARAMETER PASSED:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF "%1"=="" (
    echo [.WARN] NO PARAMETER PASSED FOR OPERATION MODE
    GOTO :PRINT_OP_MODES
)

::CHECK OPERATION MODE:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set op_mode=%1
echo [.INFO] OPERATION MODE: %op_mode%
FOR %%A in (%operation_modes%) DO (
    IF %op_mode%==%%A (
        GOTO :MAIN
    )
)
echo [.WARN] INVALID PARAMETER FOR OPERATION MODE: %op_mode%
GOTO :PRINT_OP_MODES

::PRINT_OP_MODES SUBROUTINE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRINT_OP_MODES
echo [.WARN] PLEASE PASS ONE OF THESE MODES
FOR %%A in (%operation_modes%) DO (
    echo [.OPTN] %%A
)
echo [.INFO] EXITING PROCESS
GOTO :EOF

::SHIFT VARIABLES::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SHIFT

::CHECK IF ADDITIONAL PARAMETERS PASSED::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF not "%1"=="" (
    echo [.WARN] Unexpected number of parameters passed
    echo [.INFO] EXITING PROCESS
    GOTO :EOF
)

::MAIN SUBROUTING::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MAIN
IF %op_mode%==cleanup (
    echo [.INFO] CLEANUP MODE...
    echo [.INFO] CLEANING DIRECTORIES...
    IF EXIST test rmdir /q /s test
    IF EXIST test2 rmdir /q /s test2
    GOTO :EOF
)

::CREATING REPOSITORIES::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo [.INFO] CREATING SOURCE AND TARGET REPOSITORIES
IF NOT EXIST test mkdir test
IF NOT EXIST test2 mkdir test2

echo [.INFO] SWITCHING WORKING DIRECTORY
cd test
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
echo [.INFO] INITIALIZING GIT REPO
git init
echo [.INFO] CREATE SAMPLE FILES
FOR /L %%A IN (1,1,4) DO (
    echo 1 > t%%A.txt
    git add *
    git commit --quiet -m "cmt%%A"
)

echo [.INFO] SOURCE REPO GIT LOG
git log --oneline --all --graph

echo [.INFO] SWITCHING WORKING DIRECTORY
cd ../test2
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
echo [.INFO] INITIALIZING GIT REPO
git init
echo [.INFO] CREATE SAMPLE FILES
FOR /L %%A IN (1,1,3) DO (
    echo 1 > t%%A.txt
)
git add *
git commit --quiet -m "cmt1"

echo [.INFO] TARGET REPO GIT LOG
git log --oneline --all --graph

echo [.INFO] SWITCHING WORKING DIRECTORY
cd ..
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
echo [.INFO] CALLING THE SYNC SCRIPT:
call sync.bat

echo [.INFO] CALLBACK TO DEMO SCRIPT
echo [.INFO] SWITCHING WORKING DIRECTORY
cd test2
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
echo [.INFO] TARGET REPO GIT LOG
git log --oneline --all --graph

echo [.INFO] SWITCHING WORKING DIRECTORY
cd ..
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::