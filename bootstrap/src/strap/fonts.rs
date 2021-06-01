use std::{
    fs,
    path::{Path, PathBuf},
};

use anyhow::{Context, Result};
use fs_extra::dir::CopyOptions;

#[cfg(target_os = "linux")]
const CFG_DIR: &str = "~/.local/share/fonts";

#[cfg(target_os = "macos")]
const CFG_DIR: &str = "~/Library/Fonts";

fn get_font_dir() -> PathBuf {
    PathBuf::from(shellexpand::tilde(CFG_DIR).to_string())
}

fn font_copy_options() -> CopyOptions {
    CopyOptions {
        overwrite: true,
        skip_exist: true,
        ..Default::default()
    }
}

pub fn fonts(dotfiles_dir: &Path) -> Result<()> {
    println!("[fonts]");
    let src_font_dir = dotfiles_dir.join("fonts");
    let dst_font_dir = get_font_dir();

    if !dst_font_dir.exists() {
        fs::create_dir_all(&dst_font_dir)?;
    }

    for entry in std::fs::read_dir(&src_font_dir)?
        .into_iter()
        .filter_map(|f| f.ok())
    {
        if entry.file_name().to_string_lossy().starts_with('.')
            || !entry.path().is_dir()
            || entry.path() == src_font_dir
        {
            continue;
        }

        println!("- {}", entry.file_name().to_string_lossy());
        fs_extra::dir::copy(&entry.path(), &dst_font_dir, &font_copy_options()).context(
            format!(
                "failed to copy font {:?} to {:?}",
                &entry.path(),
                &dst_font_dir
            ),
        )?;
    }

    Ok(())
}
