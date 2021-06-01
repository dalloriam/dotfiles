use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Command;

use anyhow::{ensure, Result};

const SCRIPTS_SRC_DIR: &str = "scripts";

fn is_executable(path: &Path) -> Result<bool> {
    let file = fs::File::open(path)?;
    let permissions = file.metadata()?.permissions();
    Ok(permissions.mode() & 0o111 != 0)
}

fn run_fish(path: &Path) -> Result<()> {
    println!("- Running fish script '{}'", path.to_string_lossy());
    let mut cmd = Command::new("fish").arg(path).spawn()?;
    let exit_status = cmd.wait()?;
    ensure!(
        exit_status.success(),
        "failed to run script (status {})",
        exit_status
    );

    Ok(())
}

fn run(path: &Path) -> Result<()> {
    let mut cmd = Command::new(path).spawn()?;
    let exit_status = cmd.wait()?;
    ensure!(
        exit_status.success(),
        "failed to run script (status {})",
        exit_status
    );

    Ok(())
}

pub fn scripts(dotfiles_dir: &Path) -> Result<()> {
    println!("[scripts]");
    let src_path = dotfiles_dir.join(SCRIPTS_SRC_DIR);

    for script in fs::read_dir(src_path)?.into_iter().filter_map(|f| f.ok()) {
        if let Some(ext) = script.path().extension() {
            if ext.to_string_lossy().to_lowercase() == "fish" {
                run_fish(&script.path())?;
            }
        } else if is_executable(&script.path())? {
            run(&script.path())?;
        }
    }
    Ok(())
}
