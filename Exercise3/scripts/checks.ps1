param()

function Check-Command($name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Error "Required command '$name' not found in PATH."
        return $false
    }
    return $true
}

$ok = $true
$ok = $ok -and (Check-Command -name "minikube")
$ok = $ok -and (Check-Command -name "kubectl")
$ok = $ok -and (Check-Command -name "docker")

if ($ok) { Write-Output "All required commands found: minikube, kubectl, docker." }
else { Write-Error "Please install missing tooling before proceeding."; exit 1 }
