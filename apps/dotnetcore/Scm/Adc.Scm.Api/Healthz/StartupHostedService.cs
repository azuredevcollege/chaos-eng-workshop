using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Adc.Scm.Repository.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Adc.Scm.Repository.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

public class StartupHostedService : IHostedService, IDisposable
{
    private readonly ILogger _logger;
    private IConfiguration _configuration { get; }
    private readonly StartupHostedServiceHealthCheck _startupHostedServiceHealthCheck;
    private readonly IServiceProvider _serviceProvider;

    private volatile bool _run = true;

    public StartupHostedService(IConfiguration configuration, ILogger<StartupHostedService> logger,
        StartupHostedServiceHealthCheck startupHostedServiceHealthCheck, IServiceProvider serviceProvider)
    {
        _configuration = configuration;
        _logger = logger;
        _startupHostedServiceHealthCheck = startupHostedServiceHealthCheck;
        _serviceProvider = serviceProvider;
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Startup Background Service is starting.");

        // Simulate the effect of a long-running startup task.
        Task.Run(async () =>
        {
            var _delaySeconds = _configuration.GetValue<Nullable<int>>("ReadinessDelaySeconds");
            var timeoutTask = Task.Delay((int)(_delaySeconds != null ? _delaySeconds * 1000 : 15 * 1000));

            using (var scope = _serviceProvider.CreateScope())
            {
                try
                {
                    // ensure that DB schema is created
                    var ctx = scope.ServiceProvider.GetService<ContactDbContext>();
                    await ctx.Database.EnsureCreatedAsync();
                } 
                catch (Exception )
                {
                }        
            }
        
            await timeoutTask;
            _startupHostedServiceHealthCheck.StartupTaskCompleted = true;

            while (_run)
            {
                using (var scope = _serviceProvider.CreateScope())
                {
                    try
                    {
                        // ensure that DB schema is created
                        var ctx = scope.ServiceProvider.GetService<ContactDbContext>();
                        var timeout = ctx.Database.GetCommandTimeout();
                        ctx.Database.SetCommandTimeout(1);
                        await ctx.Database.ExecuteSqlRawAsync("SELECT 1");
                        ctx.Database.SetCommandTimeout(timeout);
                    } 
                    catch (Exception )
                    {
                    }        

                    await Task.Delay(1000);
                }
            }

            _logger.LogInformation("Startup Background Service stopped.");
        });

        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Startup Background Service is stopping.");

        return Task.CompletedTask;
    }

    public void Dispose()
    {
    }
}