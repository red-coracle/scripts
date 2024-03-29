$gog_hashes = "0db093590538192f52b39c94119a48cb",
"0b84cdeccabf7d06904bfbe923c3cfea",
"0b2ce86937cd32092d0c003efdf5d988",
"06f56dd38538018e9a31248796e640ab",
"05b5d9d6bb2960fbd330c5d6b9b7b7d2",
"096dcf2e35c66f13ef95fcc8bfac3e11",
"0b17a63f5d10cb7d3b78af8f676c7667"

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
