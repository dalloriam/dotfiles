use std::{path::Path, str::FromStr};

use anyhow::{anyhow, Result};

mod binman;
mod cloud;
mod config;
mod dotfiles;
#[cfg(unix)]
mod fonts;
mod menmos;
mod repo;
mod scripts;
mod tools;
mod util;

pub enum Target {
    #[cfg(unix)]
    Fonts,
    Config,
    Dotfiles,
    Tools,
    Scripts,
    Cloud,
    Menmos,
    Binman,
}

impl Target {
    pub fn interactive(&self) -> bool {
        match &self {
            Target::Cloud | Target::Menmos => true,
            _ => false,
        }
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
            "menmos" => Target::Menmos,
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
        Target::Menmos => menmos::menmos(dotfiles_dir).await,
        Target::Binman => binman::binman_packages(dotfiles_dir).await,
    }
}

pub async fn single(target: Target) -> anyhow::Result<()> {
    let dotfiles_dir = repo::repo()?;
    single_target(target, &dotfiles_dir).await
}

pub async fn all(interactive: bool) -> anyhow::Result<()> {
    let dotfiles_dir = repo::repo()?;

    let targets = vec![
        Target::Menmos,
        #[cfg(unix)]
        Target::Fonts,
        Target::Config,
        Target::Dotfiles,
        Target::Tools,
        Target::Binman,
        Target::Scripts,
        Target::Cloud,
    ];

    for target in targets.into_iter() {
        // Skip interactive targets in non-interactive mode.
        if !interactive && target.interactive() {
            continue;
        }

        single_target(target, &dotfiles_dir).await?;
    }

    Ok(())
}
