param(
  [int]$Iterations = 5
)

if ($Iterations -lt 1) {
  throw "Iterations must be at least 1."
}

$ErrorActionPreference = "Stop"
$samples = @()

Write-Output "Warming up: moon run cmd/main -- benchmark"
moon run cmd/main -- benchmark | Out-Null

for ($i = 1; $i -le $Iterations; $i++) {
  $elapsed = Measure-Command {
    moon run cmd/main -- benchmark | Out-Null
  }
  $ms = [math]::Round($elapsed.TotalMilliseconds, 3)
  $samples += $ms
  Write-Output ("sample={0} wall_clock_ms={1}" -f $i, $ms)
}

$ordered = @($samples | Sort-Object)
$median = if ($ordered.Count % 2 -eq 1) {
  $ordered[[int]($ordered.Count / 2)]
} else {
  ($ordered[($ordered.Count / 2) - 1] + $ordered[$ordered.Count / 2]) / 2.0
}

Write-Output ("summary=wall_clock_ms min={0} median={1} max={2}" -f $ordered[0], $median, $ordered[$ordered.Count - 1])
Write-Output ""
moon run cmd/main -- benchmark
