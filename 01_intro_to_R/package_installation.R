# To install use install.packages()
# Only need to install once per machine/environment (but can repeat to update to latest)
# Bad practice to include in scripts, especially if used by others
# Therefore most of this script is commented out using hashtags

# install.packages("remotes")

# To load a package use library()

library(remotes)

# To install a package from github, use install_github() from the remotes package
# This example is a package of colour palettes based on US national park posters

# With package explicitly named (do not need to load before with this method):
# remotes::install_github("https://github.com/katiejolly/nationalparkcolors")

# Or without explicit naming (needs to be loaded with library()):
# install_github("https://github.com/katiejolly/nationalparkcolors")
