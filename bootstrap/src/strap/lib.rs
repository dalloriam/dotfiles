use std::{path::Path, str::FromStr};

use anyhow::{anyhow, Result};

mod config;
mod dotfiles;
mod fonts;
mod repo;
mod scripts;
mod tools;
mod util;

pub enum Target {
    Fonts,
    Config,
    Dotfiles,
    Tools,
    Scripts,
}

impl FromStr for Target {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self> {
        let tgt = match s {
            "fonts" => Target::Fonts,
            "config" => Target::Config,
            "dotfiles" => Target::Dotfiles,
            "tools" => Target::Tools,
            "scripts" => Target::Scripts,
            _ => {
                return Err(anyhow!("unknown target: '{}'", s));
            }
        };

        Ok(tgt)
    }
}

fn single_target(target: Target, dotfiles_dir: &Path) -> anyhow::Result<()> {
    match target {
        Target::Fonts => fonts::fonts(dotfiles_dir),
        Target::Config => config::config(dotfiles_dir),
        Target::Dotfiles => dotfiles::dotfiles(dotfiles_dir),
        Target::Tools => tools::tools(dotfiles_dir),
        Target::Scripts => scripts::scripts(dotfiles_dir),
    }
}

pub fn single(target: Target) -> anyhow::Result<()> {
    let dotfiles_dir = repo::repo()?;
    single_target(target, &dotfiles_dir)
}

pub fn all() -> anyhow::Result<()> {
    let dotfiles_dir = repo::repo()?;

    vec![
        Target::Fonts,
        Target::Config,
        Target::Dotfiles,
        Target::Tools,
        Target::Scripts,
    ]
    .into_iter()
    .map(|target| single_target(target, &dotfiles_dir))
    .collect::<Result<Vec<_>>>()?;

    Ok(())
}
