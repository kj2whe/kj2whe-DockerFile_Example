# Use the specified Windows Server Core image as the base image
FROM mcr.microsoft.com/windows/servercore:10.0.17763.1158-amd64 as build

## Set the working directory for the build process
WORKDIR /src_sdk

# Download and install .NET 8.0 SDK
RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/d1adccfa-62de-4306-9410-178eafb4eeeb/48e3746867707de33ef01036f6afc2c6/dotnet-sdk-8.0.303-win-x64.exe -OutFile dotnet-sdk.exe; \
    Start-Process dotnet-sdk.exe -ArgumentList '/install', '/quiet', '/norestart' -NoNewWindow -Wait
    # Remove-Item -Force dotnet-sdk.exe