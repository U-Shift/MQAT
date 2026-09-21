# 1. Use pre-compiled binary packages to avoid errors due to missing dependencies
# Replace 'resolute' with Ubuntu codename
# $ lsb_release -a # For Ubuntu original distro
# $ source /etc/upstream-release/lsb-release && echo $DISTRIB_CODENAME # For other Ubuntu based distros
options(
  repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/resolute/latest"),
  HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"]))
)

# 2. Disable bspm interception (use pre-compiled Linux binaries directly from Posit without needing apt or system privileges)
# install.packages(c("bspm"))
bspm::disable()

# 3. Install
install.packages(c(
  "tidyverse", "readxl", "skimr", "DataExplorer", "corrplot",
  "car", "olsrr", "cluster", "mclust", "factoextra",
  "foreign", "nFactors", "psych", "GPArotation", "summarytools",
  "sf", "mapview", "centr", "od", "osmextract", "stplanr",
  "openrouteservice", "r5r", "rmarkdown", "tinytex", "summarytools"
))
