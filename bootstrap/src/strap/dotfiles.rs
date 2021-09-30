use std::fs;
use std::path::{Path, PathBuf};

use anyhow::Result;

use walkdir::WalkDir;

use super::util;

const DST_DIR: &str = "~";
const DOTFILES_SRC_DIR: &str = "dotfiles";

pub fn dotfiles(dotfiles_dir: &Path) -> Result<()> {
    println!("[dotfiles]");

    let src_dir = dotfiles_dir.join(DOTFILES_SRC_DIR);
    let dst_dir = PathBuf::from(shellexpand::tilde(DST_DIR).to_string());

    for entry in WalkDir::new(&src_dir).into_iter().filter_map(|f| f.ok()) {
        if entry.file_name().to_string_lossy().starts_with('.') || entry.path().is_dir() {
            continue;
        }

        let dst_path = dst_dir.join(format!(".{}", entry.file_name().to_string_lossy()));
        if dst_path.exists() {
            fs::remove_file(&dst_path)?;
        }

        util::symlink(entry.path(), &dst_path)?;
        println!("- {:?}", dst_path);
    }

    Ok(())
}
