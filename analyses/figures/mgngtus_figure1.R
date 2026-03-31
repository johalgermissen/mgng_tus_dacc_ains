# =========================
# Figure 1F-style plots
# Koutsoumpari Nomiki 
# June 2025
# adjusted for exporting source data by Johannes Algermissen, March 2025.
# =========================

# ============================================================================ #
#### Set directories, load packages and custom functions: ####

## Set codeDir:
codeDir    <- dirname(dirname(rstudioapi::getSourceEditorContext()$path))
helperDir <- file.path(codeDir, "regression", "helpers")

## Load directories:
rootDir <- dirname(codeDir)
source(file.path(helperDir, "set_dirs.R")) # Load packages and options settings
dirs <- set_dirs(rootDir)
dirs$source <- file.path(dirs$root, "results", "cbm", "source")

## Load packages:
library(dplyr)
library(ggplot2)
library(scales)
library(patchwork)
library(svglite)

# csv files import
pressurePa_ct_space <- read.csv("pressurePa_ct_space.csv")
temperature_ct_space<- read.csv("temperature_ct_space.csv")

# target order exactly as requested
target_order <- c("l-aIns", "r-aIns", "dACC")

# prepare full datasets
pressure_target <- pressurePa_ct_space %>%
  select(ID, Target, Peak.value.in.Sphere) %>%
  mutate(
    Target = recode(Target,
                    "lai" = "aIns left",
                    "rai" = "aIns right",
                    "dacc" = "dACC",
                    "l-aIns" = "aIns left",
                    "r-aIns" = "aIns right",
                    "dACC" = "dACC"),
    Target = factor(Target, levels = c("aIns left", "aIns right", "dACC")),
    Pressure_kPa = Peak.value.in.Sphere / 1000
  )

# Reshape into wide format, save to source:
pressure_long <- pressure_target[, c("ID", "Target", "Pressure_kPa")]
pressure_wide <- reshape(pressure_long, direction = "wide",
                         idvar = "ID", v.names = "Pressure_kPa", timevar = "Target")
## Save:
write.table(pressure_wide[, c(4, 2, 3)], file.path(dirs$source, "Fig1F_Pressure.csv"), sep = ",", row.names = F, col.names = F)

temperature_target <- temperature_ct_space %>%
  select(ID, Target, Peak.value.in.Sphere) %>%
  mutate(
    Target = recode(Target,
                    "lai" = "aIns left",
                    "rai" = "aIns right",
                    "dacc" = "dACC",
                    "l-aIns" = "aIns left",
                    "r-aIns" = "aIns right",
                    "dACC" = "dACC"),
    Target = factor(Target, levels = c("aIns left", "aIns right", "dACC")),
    TempRise = Peak.value.in.Sphere - 37
  )

# Reshape into wide format, save to source:
temp_long <- temperature_target[, c("ID", "Target", "TempRise")]
temp_wide <- reshape(temp_long, direction = "wide",
                         idvar = "ID", v.names = "TempRise", timevar = "Target")
## Save:
write.table(temp_wide[, c(4, 2, 3)], file.path(dirs$source, "Fig1F_Temp.csv"), sep = ",", row.names = F, col.names = F)

# colors: both insula targets same color, dACC different
target_colors <- c(
  "aIns left" = "#8E63CE",
  "aIns right" = "#8E63CE",
  "dACC"   = "#D8B43D"
)

# pressure plot
p_pressure <- ggplot(pressure_target, aes(x = Target, y = Pressure_kPa, fill = Target)) +
  geom_boxplot(width = 0.55, outlier.shape = NA, colour = "black", linewidth = 0.5) +
  geom_jitter(width = 0.10, height = 0, size = 1.8, alpha = 0.9, colour = "black") +
  scale_fill_manual(values = target_colors) +
  scale_y_continuous(
    name = "Peak pressure at target (kPa)",
    labels = label_number(accuracy = 1)
  ) +
  labs(x = NULL) +
  theme_classic(base_size = 12) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(colour = "black"),
    axis.text.y = element_text(colour = "black"),
    axis.title = element_text(colour = "black")
  )

# temperature rise plot
p_temp <- ggplot(temperature_target, aes(x = Target, y = TempRise, fill = Target)) +
  geom_boxplot(width = 0.55, outlier.shape = NA, colour = "black", linewidth = 0.5) +
  geom_jitter(width = 0.10, height = 0, size = 1.8, alpha = 0.9, colour = "black") +
  scale_fill_manual(values = target_colors) +
  scale_y_continuous(
    name = "Temperature rise at target (°C)",
    limits = c(0, 0.3),
    breaks = c(0, 0.1, 0.2, 0.3),
    labels = label_number(accuracy = 0.1)
  ) +
  labs(x = NULL) +
  theme_classic(base_size = 12) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(colour = "black"),
    axis.text.y = element_text(colour = "black"),
    axis.title = element_text(colour = "black")
  )

# combine vertically
p_pressure / p_temp

#Save
# combine vertically
fig_1F <- p_pressure / p_temp

# show them
p_pressure
p_temp
fig_1F

# save pressure only
ggsave(
  filename = "Figure_1F_pressure.svg",
  plot = p_pressure,
  width = 6,
  height = 4,
  units = "in"
)

# save temperature only
ggsave(
  filename = "Figure_1F_temperature.svg",
  plot = p_temp,
  width = 6,
  height = 4,
  units = "in"
)

# save combined figure
ggsave(
  filename = "Figure_1F_combined.svg",
  plot = fig_1F,
  width = 6,
  height = 8,
  units = "in"
)

