# Use the specified Windows Server Core image as the base image
FROM mcr.microsoft.com/windows/servercore:10.0.17763.1158-amd64 as build

## Set the working directory for the build process
WORKDIR /src_runtime

# Download and install .NET 8.0 Runtime
RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/e7cd032b-21b3-4a9d-82cc-5249dd7fe092/00af1c24dd391c81df9d89cb737c9954/aspnetcore-runtime-8.0.7-win-x64.exe -OutFile dotnet-runtime.exe; \
    Start-Process dotnet-runtime.exe -ArgumentList '/install', '/quiet', '/norestart' -NoNewWindow -Wait
    # Remove-Item -Force dotnet-runtime.exe 