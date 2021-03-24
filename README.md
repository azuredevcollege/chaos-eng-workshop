# Welcome, friends!

Chaos engineering is a discipline that is becoming increasingly important, especially in the area of software development of distributed applications. Platforms like Kubernetes encourage you to develop microservice-based applications and (often times) create small independent services that communicate with each other through messaging systems. This is hoped to provide many benefits, such as faster feature releases, fewer source code dependencies, and better assigned responsibilities - among others. However, it also introduces problems which often only occur in production and under certain load. Chaos engineering helps developers to find these vulnerabilities early and to eliminate them before they affect your end users.

## Chaos Engineering Workshop

In this repository, we will guide you on how to setup and use different tools from the chaos engineering universe and "stress test" a real-world Kubernetes-based application with network failures, delays, worker node outages etc. 

It is split into several challenges that you need to solve, beginning with the setup of your Kubernetes cluster and the deployment of the application.

![architecture](./challenges/challenge-0/img/aks-architecture.png)

It is as simple as following the challenges from 0 to 4.

Happy hacking! 😄

- [Challenge 0 - Setup the environment](challenges/challenge-0/README.md)
- [Challenge 1 - Chaos Engineering "hello world"](challenges/challenge-1/README.md)
- [Challenge 2 - Spread your application over the whole cluster](challenges/challenge-2/README.md)
- [Challenge 3 - Stability also in case of network troubles](challenges/challenge-3/README.md)
- [Challenge 4 (Bonus) - Increasing reliability using availability zones](challenges/challenge-4/README.md)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.microsoft.com.>

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.