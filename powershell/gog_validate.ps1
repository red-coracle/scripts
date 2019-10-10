$authenticode = Get-ChildItem $args[0] | Get-AuthenticodeSignature

If ($authenticode.SignerCertificate.SerialNumber -eq "0b2ce86937cd32092d0c003efdf5d988") {
    Write-Host "Serial number valid" -ForegroundColor Green
    If ($authenticode.Status -eq 'Valid') {
        Write-Host "Signature valid" -ForegroundColor Green
    } Else {
        Write-Host "Signature invalid:" $authenticode.Status -ForegroundColor Red
    }
} Else {
    Write-Host "Serial number invalid" -ForegroundColor Red
}
