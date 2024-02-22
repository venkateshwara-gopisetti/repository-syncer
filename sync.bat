@echo off

set continue_flag=n
set update_params=n
set commit_diff=diff

set curdir="%cd%"
set source_repo="%cd%\test"
set source_branch="master"
set target_repo="%cd%\test2"
set target_branch="master"

echo [SETUP] DEFAULT PARAMETERS :
echo [.INFO] CURRENT DIRECTORY : %curdir%
echo [.INFO] SOURCE REPOSITORY : %source_repo%
echo [.INFO] SOURCE BRANCH     : %source_branch%
echo [.INFO] TARGET REPOSITORY : %target_repo%
echo [.INFO] TARGET BRANCH     : %target_branch%


set /p "update_params=Would you like to enter new parameters(y/[n])"
IF %update_params%==y (
    set /p "source_repo=Source Repository Name.."
    echo [.INFO] Listing all available branches in source repository
    cd %source_repo%
    git branch --all
    set /p "source_branch=Source Branch Name:"
    set /p "target_repo=Target Repository Name:"
    echo [.INFO] Listing all available branches in target repository
    cd %target_repo%
    git branch --all
    set /p "target_branch=Target Branch Name:"
)

@REM Update Source Repo

echo [.INFO] SWITCHING TO SOURCE REPOSITORY
cd %source_repo%
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
echo [.INFO] CHECKOUT SOURCE BRANCH    : %source_branch%
git checkout %source_branch%

FOR /F %%i IN ('git log -1 --pretty^=%%B') DO set commit_message=%%i
FOR /F %%i IN ('git log -1 --pretty^=%%H') DO set commit_hash=%%i
FOR /F %%i IN ('git log -1 --pretty^=%%T') DO set tree_hash=%%i

echo [.INFO] LATEST COMMIT DIFFS
git diff --stat --name-only HEAD HEAD~1 > %curdir%\source_repo_diff.txt

echo [.INFO] COPY FILES FROM SOURCE TO TARGET...
echo %cd%
echo %target_repo%
xcopy /E /Y /I . %target_repo%

echo [.INFO] SWITCHING TO TARGET REPOSITORY...
cd %target_repo%
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%

echo [.INFO] CHECKOUT TARGET BRANCH : %target_branch%
git checkout %target_branch%

echo [.INFO] LATEST COMMIT DIFFS...
FOR /F %%i IN ('git rev-list --count HEAD') DO set commit_count=%%i
IF $((%commit_count%)) GEQ 1 (
    git diff --stat --name-only HEAD HEAD~1 > %curdir%\target_repo_diff.txt
    FOR /F %%i IN ('FC %curdir%\source_repo_diff.txt %curdir%\target_repo_diff.txt ^>^NUL ^&^& Echo same ^|^| Echo diff') DO set commit_diff=%%i
)

echo [.INFO] COMMIT DIFFS COMPARE : %commit_diff%

IF %commit_diff%==same (
    GOTO :APPROVE_COMMITS
)

IF %commit_diff%==diff (
    GOTO :REJECT_COMMITS
)

:APPROVE_COMMITS
echo [.INFO] APPROVING COMMITS
del %curdir%\source_repo_diff.txt
del %curdir%\target_repo_diff.txt
git add --all
git commit -m %commit_message%
GOTO :END

:REJECT_COMMITS
echo [.INFO] REJECTING COMMITS
echo [.WARN] PLEASE CHECK THE DIFF AND VERIFY NORMALLY
set /p "continue_flag=Do you want to force push the diffs? (y/[n])"
IF %continue_flag%==y (
    echo [.INFO] FORCE PUSHING THE DIFFS
    echo [.INFO] SYNC PROCESS COMPLETE
    GOTO :APPROVE_COMMITS
)
echo [.INFO] PUSH CANCELLED
GOTO :END

:END
echo [.INFO] SWITCHING WORKING DIRECTORY
cd %curdir%
echo [.INFO] CURRENT WORKING DIRECTORY : %cd%
echo [.INFO] EXITING SYNC PROCESS....
EXIT /B