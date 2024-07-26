# Use the specified Windows Server Core image as the base image
FROM mcr.microsoft.com/dotnet/sdk:8.0-windowsservercore-ltsc2022 as build

WORKDIR /src

# Verify installation by printing the .NET version
RUN dotnet --version
RUN dotnet --list-sdks

# Copy the csproj file and restore any dependencies (use the actual path to your csproj file)
COPY ["DockerTestSolution1.csproj", "./"]
RUN dotnet restore "DockerTestSolution1.csproj"

# RUN dotnet dev-certs https --trust

# Copy the rest of the source code from the host to the container
COPY . .

# Build the application in release mode and output to /app/build
RUN dotnet build "DockerTestSolution1.csproj" -c Release -o /app/build

# Publish the application to /app/publish
RUN dotnet publish "DockerTestSolution1.csproj" -c Release -o /app/publish

# Runtime stage: uses the .NET runtime to run the application
# FROM windows-dotnet-runtime-8 as runtime
FROM mcr.microsoft.com/dotnet/sdk:8.0-windowsservercore-ltsc2022 as runtime

ARG PFX_PASSWORD

# Verify installation by printing the .NET version
RUN dotnet --version
RUN dotnet --list-sdks
RUN dotnet --list-runtimes

# Sets the working directory for the runtime environment
WORKDIR /app

# Copy the published app from the build stage to the workdir in the runtime container
COPY --from=build /app/publish .

# Sets the user ID to the application's user ID, improving security by not running as root
USER $APP_UID

# Copy the PFX files into the container at /app directory
COPY ["myUserCert.pfx", "myMachineCert.pfx", "./"]

# Using PowerShell to handle certificate import
# Import certificates to the appropriate stores
RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Import-PfxCertificate -FilePath c:\app\myUserCert.pfx -CertStoreLocation Cert:\CurrentUser\My -Password (ConvertTo-SecureString -String $env:PFX_PASSWORD -Force -AsPlainText); \
    Import-PfxCertificate -FilePath c:\app\myMachineCert.pfx -CertStoreLocation Cert:\LocalMachine\My -Password (ConvertTo-SecureString -String $env:PFX_PASSWORD -Force -AsPlainText) 

# Set the entry point for the container, specifying the DLL to run
ENTRYPOINT ["dotnet", "DockerTestSolution1.dll"]
    
