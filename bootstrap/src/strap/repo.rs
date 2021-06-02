use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::util::StackDir;

use anyhow::{ensure, Result};

const CLONE_SUFFIX: &str = "~/.dotfiles";
const DOTFILES_REPO: &str = "https://github.com/dalloriam/dotfiles"; // TODO: Make configurable.

fn update_repo(repo_path: &Path) -> Result<()> {
    println!("dotfiles directory already exists - updating...");
    let _chdir_guard = StackDir::new(repo_path)?;

    let mut cmd = Command::new("git")
        .args(&["pull", "origin", "master"])
        .spawn()?;

    let exit_status = cmd.wait()?;

    ensure!(
        exit_status.success(),
        "failed to update dotfiles repository (status {})",
        exit_status
    );

    Ok(())
}

fn clone_repo(repo_path: &Path) -> Result<()> {
    println!("cloning dotfiles repository into '{:?}'", repo_path);

    let mut cmd = Command::new("git")
        .args(&[
            "clone",
            DOTFILES_REPO,
            &repo_path.to_string_lossy().to_string(),
        ])
        .spawn()?;
    let exit_status = cmd.wait()?;

    ensure!(
        exit_status.success(),
        "failed to clone dotfiles repository (status {})",
        exit_status
    );

    Ok(())
}

pub fn repo() -> Result<PathBuf> {
    println!("[repo]");
    let cwd = env::current_dir()?;
    let dotfiles_dir = PathBuf::from(shellexpand::tilde(CLONE_SUFFIX).to_string());

    if dotfiles_dir.exists() {
        ensure!(
            dotfiles_dir.is_dir(),
            "dotfiles repo path is not a directory"
        );

        update_repo(&dotfiles_dir)?;
    } else {
        println!("cloning repository...");
        clone_repo(&dotfiles_dir)?;
    }

    Ok(dotfiles_dir)
}
