using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Adc.Scm.Repository.Interfaces;
using Microsoft.Extensions.DependencyInjection;

public class StartupHostedService : IHostedService, IDisposable
{
    private readonly ILogger _logger;
    private IConfiguration _configuration { get; }
    private readonly StartupHostedServiceHealthCheck _startupHostedServiceHealthCheck;
    private readonly IServiceProvider _serviceProvider;

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
                    // execute a default command request to initialize EF Core correctly
                    var repo = scope.ServiceProvider.GetService<IContactRepository>();
                    await repo.Get(Guid.NewGuid()); 
                } 
                catch (Exception )
                {
                }        
            }
        
            await timeoutTask;
            _startupHostedServiceHealthCheck.StartupTaskCompleted = true;

            _logger.LogInformation("Startup Background Service has started.");
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