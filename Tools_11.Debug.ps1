
$initialPath = "$HOME\Documents\WindowsPowerShell"
$data = Import-Csv -Path "$initialPath\Tools_11_Data.csv"

$totalqty = 0
$totalsold = 0
$totalbought = 0

foreach ($line in $data) {
    if ($line.transaction -eq 'buy') {
        # buy transaction (we sold)
        $totalqty -= $line.qty
        $totalsold = $line.total 
    }
    else {
        # sell transaction (we bought)
        $totalqty += $line.qty
        $totalbought = $line.total 
    }
}

"totalqty,totalbought,totalsold,totalamt" | out-file $initialPath\Tools_11_Sum.csv
"$totalqty,$totalbought,$totalsold,$($totalbought-$totalsold)" |
    out-file $initialPath\Tools_11_Sum.csv -append