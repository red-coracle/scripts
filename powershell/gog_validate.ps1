$gog_hashes = "0db093590538192f52b39c94119a48cb",
"0b84cdeccabf7d06904bfbe923c3cfea",
"0b2ce86937cd32092d0c003efdf5d988",
"06f56dd38538018e9a31248796e640ab"

Get-ChildItem "." -Recurse -Filter *.exe |
Foreach-Object {
    Write-Host -NoNewline $_.Name
    $authenticode = Get-ChildItem $_.FullName | Get-AuthenticodeSignature
    $serial = $authenticode.SignerCertificate.SerialNumber

    If ($serial -in $gog_hashes) {
        Write-Host -NoNewline " | Serial number valid" -ForegroundColor Green
        If ($authenticode.Status -eq 'Valid') {
            Write-Host " | Signature valid" -ForegroundColor Green
        } Else {
            Write-Host " | Signature invalid:" $authenticode.Status -ForegroundColor Red
        }
    } Else {
        Write-Host " | Serial number invalid" -ForegroundColor Red
    }
}
