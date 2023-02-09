use std::{path::Path, str::FromStr};

use anyhow::{anyhow, Result};

mod binman;
mod cloud;
mod config;
mod dotfiles;
#[cfg(unix)]
mod fonts;
mod scripts;
mod tools;
mod util;

#[derive(Clone, Copy, Debug)]
pub enum Target {
    #[cfg(unix)]
    Fonts,
    Config,
    Dotfiles,
    Tools,
    Scripts,
    Cloud,
    Binman,
}

impl Target {
    pub fn interactive(&self) -> bool {
        matches!(self, Target::Cloud)
    }

    pub fn all() -> Vec<Self> {
        vec![
            #[cfg(unix)]
            Target::Fonts,
            Target::Config,
            Target::Dotfiles,
            Target::Tools,
            Target::Binman,
            Target::Scripts,
            Target::Cloud,
        ]
    }
}

impl FromStr for Target {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self> {
        let tgt = match s {
            #[cfg(unix)]
            "fonts" => Target::Fonts,
            "config" => Target::Config,
            "dotfiles" => Target::Dotfiles,
            "tools" => Target::Tools,
            "scripts" => Target::Scripts,
            "cloud" => Target::Cloud,
            "binman" => Target::Binman,
            _ => {
                return Err(anyhow!("unknown target: '{}'", s));
            }
        };

        Ok(tgt)
    }
}

async fn single_target(target: Target, dotfiles_dir: &Path) -> anyhow::Result<()> {
    match target {
        #[cfg(unix)]
        Target::Fonts => fonts::fonts(dotfiles_dir),
        Target::Config => config::config(dotfiles_dir),
        Target::Dotfiles => dotfiles::dotfiles(dotfiles_dir),
        Target::Tools => tools::tools(dotfiles_dir),
        Target::Scripts => scripts::scripts(dotfiles_dir),
        Target::Cloud => cloud::cloud(dotfiles_dir),
        Target::Binman => binman::binman_packages(dotfiles_dir).await,
    }
}

pub async fn single(target: Target) -> anyhow::Result<()> {
    let dotfiles_dir = std::env::current_dir()?;
    let private_dotfiles_dir = std::env::current_dir()?.join("private");

    single_target(target, &dotfiles_dir).await?;
    if private_dotfiles_dir.exists() {
        single_target(target, &private_dotfiles_dir).await?;
    }
    Ok(())
}

pub async fn all(interactive: bool) -> anyhow::Result<()> {
    let dotfiles_dir = std::env::current_dir()?;
    let private_dotfiles_dir = std::env::current_dir()?.join("private");

    for target in Target::all().into_iter() {
        // Skip interactive targets in non-interactive mode.
        if !interactive && target.interactive() {
            continue;
        }

        single_target(target, &dotfiles_dir).await?;
        if private_dotfiles_dir.exists() {
            single_target(target, &private_dotfiles_dir).await?;
        }
    }

    Ok(())
}
