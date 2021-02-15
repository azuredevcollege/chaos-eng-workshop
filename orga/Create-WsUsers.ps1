Param(
    [Parameter(Mandatory=$true)]
    [String]$TenantId,
    [Parameter(Mandatory=$true)]
    [String]$TenantDomainName,
    [Parameter(Mandatory=$true)]
    [Int]$Count,
    [Parameter(Mandatory=$true)]
    [String]$Password
)

$module = Get-Module 'AzureAD.Standard.Preview' -ListAvailable -ErrorAction SilentlyContinue

Import-Module $module.RootModule

Connect-AzureAD -TenantId $TenantId

for ($i = 0; $i -lt $count; $i++) {
    $username = "User"
    $upn = "user"

    if ($i -lt 10 ) {
        $username = $username + "0" + $i
        $upn = $upn + "0" + $i + "@" + $TenantDomainName
     } else {
        $username = $username + $i
        $upn = $upn + $i + "@" + $TenantDomainName
    }

    $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $passwordProfile.ForceChangePasswordNextLogin = $False
    $passwordProfile.Password = $Password

    New-AzureADUser `
        -AccountEnabled $True `
        -DisplayName $username `
        -PasswordProfile $passwordProfile `
        -MailNickName $username `
        -UserPrincipalName $upn
}