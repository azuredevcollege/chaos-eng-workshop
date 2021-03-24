using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;

namespace Adc.Scm.Api.Monitoring
{
    public class SqlKeepAliveDependencyFilter : ITelemetryProcessor
    {
        private ITelemetryProcessor Next { get; set; }

        public SqlKeepAliveDependencyFilter(ITelemetryProcessor next)
        {
            this.Next = next;
        }
        public void Process(ITelemetry item)
        {
            var dependency = item as DependencyTelemetry;
            if (null == dependency)
            {
                this.Next.Process(item);
                return;
            }

            if (dependency.Type != "SQL")
            {
                this.Next.Process(item);
                return;
            }

            if (dependency.Data != "SELECT 1")
            {
                this.Next.Process(item);
                return;
            }
        }
    }
}