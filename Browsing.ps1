# Define the websites for each category
$websites = @{
    "work" = @("https://mail.google.com", "https://www.lucidchart.com", "https://asana.com", 
               "https://www.slack.com", "https://www.trello.com", "https://www.zoom.us", 
               "https://www.dropbox.com", "https://www.microsoft.com/en-us/microsoft-365", 
               "https://www.salesforce.com", "https://www.office.com")
    "entertainment" = @("https://www.spotify.com", "https://www.youtube.com", "https://www.netflix.com", 
                        "https://www.hulu.com", "https://www.disneyplus.com", "https://www.twitch.tv", 
                        "https://www.amazon.com/Prime-Video", "https://www.pandora.com", 
                        "https://www.apple.com/apple-tv-plus/", "https://www.hbo.com")
    "sports" = @("https://www.nba.com", "https://www.mmafighting.com", "https://www.espn.com/soccer/", 
                 "https://www.nfl.com", "https://www.mlb.com", "https://www.espncricinfo.com", 
                 "https://www.formula1.com", "https://www.nhl.com", "https://www.cbssports.com", 
                 "https://www.foxsports.com")
    "news" = @("https://www.bbc.com/news", "https://www.cnn.com", "https://www.reuters.com", 
               "https://www.nytimes.com", "https://www.theguardian.com", "https://www.washingtonpost.com", 
               "https://www.aljazeera.com", "https://www.bloomberg.com", "https://www.nbcnews.com", 
               "https://www.foxnews.com")
    "finance" = @("https://www.marketwatch.com", "https://www.forex.com", "https://www.investopedia.com", 
                  "https://www.bloomberg.com/markets", "https://www.cnbc.com/finance", "https://www.ft.com/markets", 
                  "https://www.wsj.com/market-data", "https://www.tradingview.com", "https://www.fidelity.com", 
                  "https://www.robinhood.com")
}

# Function to make web requests with sleep intervals
function Make-WebRequestWithSleep {
    param (
        [string[]]$urls,
        [int]$requestCount = 10
    )

    for ($i = 0; $i -lt $requestCount; $i++) {
        $url = Get-Random -InputObject $urls
        try {
            Write-Output "Requesting $url"
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing
            Write-Output "Response status code: $($response.StatusCode)"
        }
        catch {
            Write-Output "Failed to request $url"
        }
        
        # Sleep for a random interval between 1 and 10 seconds
        $sleepInterval = Get-Random -Minimum 3 -Maximum 10
        Write-Output "Sleeping for $sleepInterval seconds"
        Start-Sleep -Seconds $sleepInterval
    }
}

# Main script logic
foreach ($category in $websites.Keys) {
    Write-Output "Starting requests for category: $category"
    Make-WebRequestWithSleep -urls $websites[$category]
    Write-Output "Completed requests for category: $category"
    Write-Output "Sleeping for 5 seconds before next category"
    Start-Sleep -Seconds 5
}
