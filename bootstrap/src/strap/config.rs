use std::fs;
use std::path::{Path, PathBuf, MAIN_SEPARATOR};

use anyhow::Result;

use walkdir::WalkDir;

use super::util;

const CONFIG_DIR: &str = "~/.config";
const CONFIG_DOTFILES_PATH: &str = "config";

pub fn config(dotfiles_dir: &Path) -> Result<()> {
    println!("[config]");
    let src_dir = dotfiles_dir.join(CONFIG_DOTFILES_PATH);
    let dst_dir = PathBuf::from(shellexpand::tilde(CONFIG_DIR).to_string());

    for entry in WalkDir::new(&src_dir).into_iter().filter_map(|e| e.ok()) {
        if entry.path().is_dir() {
            continue;
        }

        let dst_path = dst_dir.join(
            entry
                .path()
                .to_string_lossy()
                .to_string()
                .replace(&src_dir.to_string_lossy().to_string(), "")
                .strip_prefix(MAIN_SEPARATOR)
                .unwrap()
                .to_string(),
        );

        if let Some(parent) = dst_path.parent() {
            fs::create_dir_all(parent)?;
        }

        if dst_path.exists() {
            fs::remove_file(&dst_path)?;
        }

        util::symlink(entry.path(), &dst_path)?;

        println!("- {:?}", dst_path);
    }

    Ok(())
}
