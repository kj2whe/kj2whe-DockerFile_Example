using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using System.Data.SqlClient; 
using System.Security.Cryptography.X509Certificates;

// Set up Dependency Injection and Logging
var services = new ServiceCollection();
services.AddLogging(builder =>
{
    builder.AddConsole();
    builder.SetMinimumLevel(LogLevel.Information); // Configure the minimum log level
});

var serviceProvider = services.BuildServiceProvider();

// Get the logger
var logger = serviceProvider.GetRequiredService<ILogger<Program>>();

logger.LogInformation("Testing Logger functionality.  This should appear in the container logs.");

// Define the connection string
var connectionString = "Server=192.168.1.3;Database=AdventureWorks2019;User Id=SA;Password=!!050206!!Qzwxecrv!!;TrustServerCertificate=True;";

// Create and open a connection
using (var connection = new SqlConnection(connectionString))
{
    try
    {
        connection.Open();
        logger.LogInformation("Connection to SQL Server opened successfully.");

        // Create a command object
        var sql = "SELECT TOP 1 * FROM [AdventureWorks2019].[Person].[Address]";
        using var command = new SqlCommand(sql, connection);
        // Execute the command and process results
        using var reader = command.ExecuteReader();
        // Log information
        logger.LogInformation("Data returned from SQL Server");
        while (reader.Read())
        {
            logger.LogInformation($"Address: {reader["AddressLine1"]}, City: {reader["City"]}");
        }
    }
    catch (SqlException ex)
    {
        logger.LogError($"An error occurred: {ex.Message}");
    }
}

logger.LogInformation($"Before getting LocalMachine Cert");

using X509Store storeLocalMachine = new X509Store(StoreName.My, StoreLocation.LocalMachine);
storeLocalMachine.Open(OpenFlags.ReadOnly);
var certsLocalMachine = storeLocalMachine.Certificates.Find(X509FindType.FindBySubjectName, "MachineTestCertificateForContainer", false);
if (certsLocalMachine.Count > 0)
{
    using X509Certificate2 certLocalMachine = certsLocalMachine[0];
    // Use the certificate, e.g., for HTTPS client or server operations
    logger.LogInformation($"Certificate found in Machine Store: {certLocalMachine.Subject}");
}
storeLocalMachine.Close();

logger.LogInformation($"After getting LocalMachine Cert");
logger.LogInformation($"Before getting CurrentUser Cert");

using X509Store storeCurrentUser = new X509Store(StoreName.My, StoreLocation.CurrentUser);
storeCurrentUser.Open(OpenFlags.ReadOnly);
var certsCurrentUser = storeCurrentUser.Certificates.Find(X509FindType.FindByThumbprint, "b81a035e841872dcb612576df3cea2b6c0c47f15", false);
if (certsCurrentUser.Count > 0)
{
    using X509Certificate2 certCurrentUser = certsCurrentUser[0];
    // Use the certificate, e.g., for HTTPS client or server operations
    logger.LogInformation($"Certificate found in Current User Store: {certCurrentUser.Subject}");
}
storeCurrentUser.Close();
logger.LogInformation($"After getting CurrentUser Cert");

// Example of keeping the console window open
// Console.ReadLine();