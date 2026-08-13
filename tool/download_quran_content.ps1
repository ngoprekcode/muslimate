param(
  [string]$ArabicOutputPath = "assets/quran/core/verses_uthmani.json",
  [string]$IndonesianOutputPath = "assets/quran/languages/id/ayah_translations.json",
  [string]$EnglishOutputPath = "assets/quran/languages/en/ayah_translations.json"
)

$ErrorActionPreference = "Stop"
$apiBase = "https://api.quran.com/api/v4/quran"
$arabicResponse = Invoke-RestMethod "$apiBase/verses/uthmani"
$indonesianResponse = Invoke-RestMethod "$apiBase/translations/33"
$englishResponse = Invoke-RestMethod "$apiBase/translations/20"

$arabic = @($arabicResponse.verses)
$indonesian = @($indonesianResponse.translations)
$english = @($englishResponse.translations)

if ($arabic.Count -ne 6236 -or $indonesian.Count -ne $arabic.Count -or $english.Count -ne $arabic.Count) {
  throw "Unexpected Quran content size. Arabic=$($arabic.Count), Indonesian=$($indonesian.Count), English=$($english.Count)"
}

function Convert-TranslationText([string]$Text) {
  $withoutTags = $Text -replace '<[^>]+>', ''
  return [System.Net.WebUtility]::HtmlDecode($withoutTags).Trim()
}

$verses = for ($index = 0; $index -lt $arabic.Count; $index++) {
  $keyParts = $arabic[$index].verse_key.Split(':')
  [ordered]@{
    id = [int]$arabic[$index].id
    surah = [int]$keyParts[0]
    ayah = [int]$keyParts[1]
    arabic = [string]$arabic[$index].text_uthmani
  }
}

$arabicContent = [ordered]@{
  schemaVersion = 1
  source = [ordered]@{
    name = "Quran Foundation"
    url = "https://quran.com"
    api = "$apiBase/verses/uthmani"
    script = "uthmani"
  }
  verses = $verses
}

function New-TranslationPackage(
  [string]$Language,
  [int]$ResourceId,
  [string]$Name,
  [object[]]$Values
) {
  $translations = [ordered]@{}
  for ($index = 0; $index -lt $Values.Count; $index++) {
    $translations[[string]$arabic[$index].id] = Convert-TranslationText ([string]$Values[$index].text)
  }
  return [ordered]@{
    schemaVersion = 1
    language = $Language
    source = [ordered]@{
      name = $Name
      url = "https://quran.com"
      api = "$apiBase/translations/$ResourceId"
      resourceId = $ResourceId
    }
    ayahTranslations = $translations
  }
}

function Write-Json([object]$Value, [string]$Path) {
  $absolutePath = Join-Path (Get-Location) $Path
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $absolutePath) | Out-Null
  $json = $Value | ConvertTo-Json -Depth 8 -Compress
  [System.IO.File]::WriteAllText($absolutePath, $json, [System.Text.UTF8Encoding]::new($false))
  Write-Output "Wrote $absolutePath"
}

Write-Json $arabicContent $ArabicOutputPath
Write-Json (New-TranslationPackage "id" 33 "Indonesian Islamic Affairs Ministry" $indonesian) $IndonesianOutputPath
Write-Json (New-TranslationPackage "en" 20 "Saheeh International" $english) $EnglishOutputPath
Write-Output "Validated $($verses.Count) aligned ayahs"
